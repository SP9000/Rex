.include "base.inc"
.include "constants.inc"
.include "handlers.inc"
.include "types.inc"
.CODE

;--------------------------------------
; poll waits for input on the joystick and returns when it is found.
; .X returns the x-direction, .Y the y-axis, and .A is !0 if the fire button
; was pressed.
.export __joy_poll
.proc __joy_poll
@fire=zp::tmp0
        lda #$00
        sta $9113       ;set DDR for VIA #1 to input for joystick
        lda #$7f
        sta $9122       ;set DDR for VIA #2 to input for joy switch 3

	ldx #$00
	ldy #$00
	sty @fire

@poll:
        lda #$04
@chku:  bit $9111       ;up pressed?
        bne @chkd
	dey

@chkd:  lda #$08
        bit $9111       ;down pressed?
        bne @chkl
	iny

@chkl:  lda #$10
        bit $9111       ;left pressed?
        bne @chkf
	dex

@chkf:  lda #$20
        bit $9111       ;fire pressed?
        bne @chkr
	inc @fire

@chkr:  lda $9120       ;right button pressed? (bit 7)
        bmi @done
	inx
@done:
	; reset DDR and return
	lda #$80
	sta $9113
	lda #$ff
	sta $9122

	lda @fire
	beq :+
	rts
:	cpx #$00
	beq :+
	rts
:	cpy #$00
	bne @poll
	rts
.endproc

;--------------------------------------
; handle runs the handler for inputs that are pressed.
; Returns the carry set if a handler was activated.
.export __joy_handle
.proc __joy_handle
        lda #$00
        sta $9113       ;set DDR for VIA #1 to input for joystick
        lda #$7f
        sta $9122       ;set DDR for VIA #2 to input for joy switch 3

	ldx app::cursor
	ldy app::cursor+1
	jsr sprite::off

        lda #$04
@chku:  bit $9111       ;up pressed?
        bne @chkd
        on_up           ;do the up button behavior
@chkd:  lda #$08
        bit $9111       ;down pressed?
        bne @chkl
        on_down         ;do the down button behavior
@chkl:  lda #$10
        bit $9111       ;left pressed?
        bne @chkf
        on_left         ;do the down button behavior
@chkf:  lda #$20
        bit $9111       ;fire pressed?
        bne @chkr
	jsr fire
@chkr:  lda $9120       ;right button pressed? (bit 7)
        bmi @done
        on_right        ;do the fire button behavior
@done:

	ldx app::cursor
	ldy app::cursor+1
	jsr sprite::on

	; reset DDR and return
	lda #$80
	sta $9113
	lda #$ff
	sta $9122
 	rts
.endproc

;--------------------------------------
.proc fire
	ldx xpos
	ldy ypos
	lda action
	cmp #ACTION_LOOK
	bne :+
	jmp room::look
:	cmp #ACTION_USE
	bne :+
	jmp room::use
:	rts
.endproc
