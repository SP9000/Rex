.include "file.inc"
.include "gui.inc"
.include "zeropage.inc"
.include "memory.inc"
.CODE

ROOM_WIDTH = 96/8
ROOM_HEIGHT = 112

;--------------------------------------
numrooms: .byt 0
numexits: .byt 0

;--------------------------------------
;load
;
.export __room_load
.proc __room_load
@room = zp::tmp0
@src = zp::tmp0
@dst = zp::tmp2
	jsr file::load	; load into spare memory

	ldx #<mem::spare
	ldy #>mem::spare
	stx @src
	sty @src+1
	ldx #<($1100 + ($c0*4) + 16)
	ldy #>($1100 + ($c0*4) + 16)
	stx @dst
	sty @dst+1

	ldx #ROOM_WIDTH
@l1:	ldy #$00
@l0:	lda (@src),y
	sta (@dst),y
	iny
	cpy #ROOM_HEIGHT
	bne @l0

	lda @src
	clc
	adc #ROOM_HEIGHT
	bcc :+
	inc @src+1
:	sta @src

	lda @dst
	clc
	adc #$c0
	bcc :+
	inc @dst+1
:	sta @dst
	dex
	bne @l1

	rts

	stx @room
	sty @room+1

	ldy #$00
	lda (@room),y
	sta numrooms
	iny
	lda (@room),y
	sta numexits
	iny
	tya
	adc @room
	tax
	lda #$00
	adc @room+1
	tay
	jsr gui::txt
	rts
.endproc
