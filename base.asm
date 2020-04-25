.include "gui.inc"
.include "fx.inc"
.include "text.inc"

; relative coordinates of mouse in sprite handlers
.export relx
relx: .byte 0
.export rely
rely: .byte 0

diemsg: .byte "your journey ends here.",0

;--------------------------------------
; die runs the game over scenario
.export die
.proc die
	blink2 #2
	jsr gui::clrtxt
	lda #40
	sta text::speed
	ldx #<diemsg
	ldy #>diemsg
	jsr gui::txt
	lda #0
	sta text::speed
	rts
.endproc
