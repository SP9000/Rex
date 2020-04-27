.include "app.inc"
.include "fx.inc"
.include "gui.inc"
.include "room.inc"
.include "sfx.inc"
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
	lda $900f
	pha

	lda #$22|$08
	sta $900f
	ldx #<diemsg
	ldy #>diemsg
	jsr alert

	; turn off active action
	lda #$00
	jsr app::setaction

	pla
	sta $900f
	rts
.endproc

;--------------------------------------
; hit runs a routine to simulate the player or enemy being hit
.export hit
.proc hit
	jsr sfx::hit
	blink2 #2
	rts
.endproc

;--------------------------------------
.export remove
.proc remove
	jmp room::remove
.endproc

;--------------------------------------
.export alert
.proc alert
	txa
	pha
	tya
	pha

	jsr gui::clrtxt
	pla
	tay
	pla
	tax
	lda #40
	sta text::speed
	jsr gui::alert
	lda #0
	sta text::speed
	rts
.endproc
