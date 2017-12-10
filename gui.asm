.include "inventory.inc"
.include "sprite.inc"
.include "text.inc"
.include "thing.inc"
.include "zeropage.inc"

.CODE

; the bounds of the text area
TXT_ROW_START = 20
TXT_ROW_STOP  = 22
TXT_COL_START = 2
TXT_COL_STOP  = 18

; the bounds of the inventory area
INV_XSTART = 20
INV_XSTOP  = 120
INV_YSTART = 14
INV_YSTOP = 20


; bounds of scrolldown button
SCROLLDOWN_X = 152
SCROLLDOWN_Y = 120
SCROLLDOWN_W = 8
SCROLLDOWN_H = 8

; bounds of scrollup button
SCROLLUP_X = 152
SCROLLUP_Y = 20
SCROLLUP_W = 8
SCROLLUP_H = 8


txtscroll: .byte 0 ;# of characters the text area is scrolled
invscroll: .byte 0 ;# of pixels the inventory is scrolled


;--------------------------------------
;onfire
;Call upon fire being pressed to handle fire-sensitive GUI elements.
;
.export __onfire
.proc __onfire
	
.endproc

;--------------------------------------
;txt
;Displays the string in (YX).
;returns:
;  carry: set if there's more to display
;
.export __gui_txt
.proc __gui_txt
@done = zp::tmp0
@row = zp::tmp1
@msg = zp::tmp2
	stx @msg
	sty @msg+1

	lda #TXT_COL_START
	sta text::colstart
	lda #TXT_ROW_START
	sta @row

	ldy #$00
	sty @done
@l0:	lda (@msg),y
	beq @end
	iny
	cpy #TXT_COL_STOP-TXT_COL_START
	bcc @l0
	.byte $1c ;skw
@end:   inc @done
@draw:	sty text::len
	ldx @msg
	ldy @msg+1
	lda @row
	jsr text::puts

	lda @msg
	clc
	adc text::len
	sta @msg
	lda #$00
	adc @msg+1
	sta @msg+1

	lda @done
	bne @0
	inc @row
	lda @row
	cmp #TXT_ROW_STOP
	bcc @l0
@0:	rts
.endproc

;--------------------------------------
;drawinv
;Displays the inventory.
;
.export __gui_drawinv
.proc __gui_drawinv
@spr = zp::tmp0
@ystart = zp::tmp2
@item = zp::tmp3
@thing = zp::tmp5
	ldy #$00
	sty @ystart
	sty @item
@0:	ldy @item
	cpy inv::len
	bcc @1
	rts

@1:	lda inv::items,y
	sta @thing
	lda inv::items+1,y
	sta @thing+1

	; get the item's sprite
	ldy #Thing::sprite
	lda (@thing),y
	tax
	lda (@thing),y
	tay
	jsr sprite::load

	lda #INV_XSTART
	ldy sprite::xpos
	lda #INV_YSTART
	clc
	adc @ystart
	sta sprite::ypos
	jsr sprite::draw

	ldy #Sprite::h
	lda (@spr),y
	clc
	adc @ystart
	sta @ystart
	cmp #INV_YSTOP
	bcc @0

	rts
.endproc

;--------------------------------------
;scrollinv
;Scrolls the inventory by .A positions
;
.export __gui_scrollinv
.proc __gui_scrollinv
.endproc
