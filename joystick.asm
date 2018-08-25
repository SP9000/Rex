.include "handlers.inc"
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
.export __joy_handle
.proc __joy_handle
        lda #$00
        sta $9113       ;set DDR for VIA #1 to input for joystick
        lda #$7f
        sta $9122       ;set DDR for VIA #2 to input for joy switch 3

        lda #$04
@chku:  bit $9111       ;up pressed?
        bne @chkd
        on_up           ;do the up button behavior
	rts
@chkd:  asl
        bit $9111       ;down pressed?
        bne @chkl
        on_down         ;do the down button behavior
	rts
@chkl:  asl
        bit $9111       ;left pressed?
        bne @chkf
        on_left         ;do the down button behavior
	rts
@chkf:  asl
        bit $9111       ;fire pressed?
        bne @chkr
        on_fire         ;do the right button behavior
	rts
@chkr:  lda $9120       ;right button pressed? (bit 7)
        bmi @done
        on_right        ;do the fire button behavior
@done:  rts
.endproc

