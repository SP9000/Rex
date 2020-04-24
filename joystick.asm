.include "base.inc"
.include "constants.inc"
.include "handlers.inc"
.include "types.inc"
.CODE

;--------------------------------------
.export __joy_init
.proc __joy_init
        lda #$00
        sta $9113       ;set DDR for VIA #1 to input for joystick
        lda #$7f
        sta $9122       ;set DDR for VIA #2 to input for joy switch 3
        rts
.endproc

;--------------------------------------
; handle runs the handler for inputs that are pressed.
; Returns the carry set if a handler was activated.
.export __joy_handle
.proc __joy_handle
	ldx app::cursor
	ldy app::cursor+1
	jsr sprite::off

        lda #$00
        sta $9113       ;set DDR for VIA #1 to input for joystick
        lda #$7f
        sta $9122       ;set DDR for VIA #2 to input for joy switch 3

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
