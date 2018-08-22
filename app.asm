.include "app_sprites.inc"
.include "sprite.inc"
.CODE

;--------------------------------------
.export __app_movecur
.proc __app_movecur
	lda __app_cursor
	sta zp::tmp0
	lda __app_cursor+1
	sta zp::tmp0+1

	tya
	ldy #Sprite::ypos
	clc
	adc (zp::tmp0),y
	sta (zp::tmp0),y

	txa
	dey
	clc
	adc (zp::tmp0),y
	sta (zp::tmp0),y
	rts
.endproc

;--------------------------------------
.export __app_togglecur
.proc __app_togglecur
	ldx __app_cursor
	ldy __app_cursor+1

	cpx #<gfx::cursorsprite
	bne @setselect
	cpy #>gfx::cursorsprite
	bne @setselect

@setlook:
	ldx #<gfx::looksprite
	ldy #>gfx::looksprite
	jmp @set

@setselect:
	ldx #<gfx::cursorsprite
	ldy #>gfx::cursorsprite

@set:	stx __app_cursor
	sty __app_cursor+1
	rts
.endproc

.export __app_cursor
__app_cursor:
.word gfx::cursorsprite

looksprite:
.word gfx::cursorsprite

;--------------------------------------
.export __app_cury
.proc __app_cury
	ldy #Sprite::ypos
	.byte $2c
.endproc
.export __app_curx
.proc __app_curx
	ldy #Sprite::xpos
	lda __app_cursor
	sta @smc0
	lda __app_cursor+1
	sta @smc0+1

@smc0=*+1
	lda $ffff,y
	rts
.endproc
