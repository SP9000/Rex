.include "app_sprites.inc"
.include "base.inc"
.include "constants.inc"
.include "gui.inc"
.include "sprite.inc"
.include "types.inc"
.CODE

.export action
action: .byte 0

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
	cmp #192-8
	bcs @movex
	sta (zp::tmp0),y
@movex:
	txa
	dey
	clc
	adc (zp::tmp0),y
	cmp #160-8
	bcs @done
	sta (zp::tmp0),y
@done:	rts
.endproc

;--------------------------------------
.export __app_setaction
.proc __app_setaction
	sta action
	cmp #ACTION_USE
	beq @setselect
	cmp #ACTION_TAKE
	beq @settake
	cmp #ACTION_LOOK
	beq @setlook
@setnone:
	ldx #<@none
	ldy #>@none
	jmp @set
@setlook:
	ldx #<@look
	ldy #>@look
	jmp @set
@setselect:
	ldx #<@use
	ldy #>@use
	jmp @set
@settake:
	ldx #<@take
	ldy #>@take
@set:	jmp gui::action
@none: .byte "    ",0
@look: .byte "look",0
@use: .byte "use ",0
@take: .byte "take",0
.endproc

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

;--------------------------------------
.export __app_cursor
__app_cursor:
.word gfx::cursorsprite

