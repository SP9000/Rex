.include "bitmap.inc"
.include "inventory.inc"
.include "math.inc"
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
INV_XSTART = 4
INV_XSTOP  = 24
INV_YSTART = 14
INV_YSTOP = 96

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

; struct TextRegion console
console: .byte 0,16,16,4

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

@l0:	ldy #$00
	sty @done
@l1:	lda (@msg),y
	beq @end
	iny
	cpy #TXT_COL_STOP-TXT_COL_START
	bcc @l1
	.byte $2c ;skw
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
	bcc :+
	inc @msg+1

:	lda @done
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
@ystart = zp::tmp12
@item = zp::tmp13
@thing = zp::tmp14
	; draw a white box for the inventory area
	ldx #INV_XSTOP
	ldy #INV_YSTOP
	stx zp::tmp0
	sty zp::tmp1
	ldx #INV_XSTART
	ldy #INV_YSTART
	jsr __gui_wrect

	lda #INV_YSTART+1
	sta @ystart
	lda #$00
	sta @item

@0:	inc @item
	lda @item
	cmp inv::len
	bcc @1
	rts

@1:	asl
	tay
	lda inv::items,y
	sta @thing
	lda inv::items+1,y
	sta @thing+1

	; get the item's sprite
	ldy #Thing::sprite
	lda (@thing),y
	tax
	iny
	lda (@thing),y
	tay
	jsr sprite::load

	ldx #INV_XSTART+2
	ldy @ystart
	jsr sprite::set
	jsr sprite::draw

	lda sprite::h
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

;--------------------------------------
;textinput
.export __gui_textinput
__gui_textinput:
	jsr __gui_txt

;--------------------------------------
;input
.export __gui_input
.proc __gui_input
	rts
.endproc

;--------------------------------------
; wrect (slowly) draws a rectangle with the background color
;wrect
.export __gui_wrect
.proc __gui_wrect
@xstop=zp::tmp0
@ystop=zp::tmp1
@dst=zp::tmp2
@lmask=zp::tmp4
@rmask=zp::tmp5
@xstart=zp::tmp6
@ystart=zp::tmp7
@getdst:
	stx @xstart
	sty @ystart
	txa
	and #$f8
	lsr
	lsr
	tax
	lda bm::columns,x
	sta @dst
	lda bm::columns+1,x
	sta @dst+1

	lda @xstart
	and #$07

	tax
	lda #$00
@getlmask:
	sec
	ror
	dex
	bpl @getlmask
	sta @lmask

	lda @xstop
	sec
	sbc @xstart
	sta @xstart
	lda @xstop
	and #$07
	tax
	lda #$ff
@getrmask:
	lsr
	dex
	bpl @getrmask
	sta @rmask

	lda @lmask
	jmp @blitcol ; blit first column

@l0:	lda @xstart
	beq @done
	bpl @getmask
@done:	rts

@getmask:
	sec
	sbc #$08
	sta @xstart
	bmi @lastcol
	lda #$00
	.byt $2c
@lastcol:
	lda @rmask
@blitcol:
	sta @mask
	ldy @ystart
@mask=*+1
@l1:	lda #$00
	and (@dst),y
	sta (@dst),y
	iny
	cpy @ystop
	bcc @l1
        add16_8 @dst, #$c0
	jmp @l0
.endproc
