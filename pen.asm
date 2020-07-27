.include "bitmap.inc"
.include "memory.inc"
.include "zeropage.inc"

.export __pen_stroke
__pen_stroke: .byte 1

;--------------------------------------
; hstroke draws the # of pixels in stroke vertically (as if the pen is
; moving horizontally) at (.X, .Y)
.proc hstroke
@x=zp::tmp5
@y=zp::tmp6
@cnt=zp::tmp7
	stx @x
	sty @y
	lda __pen_stroke
	sta @cnt
@l0:	ldx @x
	ldy @y
	jsr bm::setpixel
	inc @y
	dec @cnt
	bne @l0
	rts
.endproc

;--------------------------------------
; vstroke draws the # of pixels in stroke horizontally (as if the pen is
; moving vertically) at (.X, .Y)
.proc vstroke
@x=zp::tmp5
@y=zp::tmp6
@cnt=zp::tmp7
	stx @x
	sty @y
	lda __pen_stroke
	sta @cnt
@l0:	ldx @x
	ldy @y
	jsr bm::setpixel
	inc @x
	dec @cnt
	bne @l0
	rts
.endproc

;--------------------------------------
.export __pen_restorerow
.proc __pen_restorerow
        txa
        lsr
        lsr
        lsr
	asl
        tax
	lda roombuff_columns,x
        sta zp::tmp0
	lda roombuff_columns+1,x
        sta zp::tmp0+1
	lda bm::columns+4*2,x
	adc #16
        sta zp::tmp2
	lda bm::columns+4*2+1,x
	adc #0
        sta zp::tmp2+1
	lda (zp::tmp0),y
        sta (zp::tmp2),y
        rts
.endproc

;--------------------------------------
.export __pen_hline
.proc __pen_hline
@x0 = zp::arg0
@x1 = zp::arg1
@y = zp::arg2
@l0:	ldx @x0
	ldy @y
	jsr hstroke
	inc @x0
	lda @x0
	cmp @x1
	bne @l0
	rts
.endproc

;--------------------------------------
.export __pen_vline
.proc __pen_vline
@y0 = zp::arg0
@y1 = zp::arg1
@x = zp::arg2
@l0:	ldx @x
	ldy @y0
	jsr bm::setpixel
	inc @y0
	lda @y0
	cmp @y1
	bne @l0
	rts
.endproc

;--------------------------------------
.export __pen_restorehline
.proc __pen_restorehline
@x0 = zp::arg0
@x1 = zp::arg1
@y = zp::arg2
@l0:	ldx @x0
	ldy @y
	jsr __pen_restorerow
	inc @x0
	lda @x0
	cmp @x1
	bne @l0
	rts
.endproc

;--------------------------------------
roombuff_columns:
.word mem::roombuff
.word mem::roombuff+112
.word mem::roombuff+112*2
.word mem::roombuff+112*3
.word mem::roombuff+112*4
.word mem::roombuff+112*5
.word mem::roombuff+112*6
.word mem::roombuff+112*7
.word mem::roombuff+112*8
.word mem::roombuff+112*9
.word mem::roombuff+112*10
.word mem::roombuff+112*11
.word mem::roombuff+112*12
