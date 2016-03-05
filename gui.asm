.include "text.inc"

.CODE
.scope gui

; the bounds of the text area
ROW_START = 14
ROW_END   = 22
COL_START = 2
COL_END   = 18

;--------------------------------------
;txt
;Displays the string in (YX).
;returns:
;  carry: set if there's more to display
;
.export __gui_txt
.proc __gui_txt
@done = temp0
@row = temp1
	stx addr0
	sty addr0+1

	lda #COL_START
	sta text::colstart
	lda #ROW_START
	sta @row

	ldy #$00
	sty @done
@l0:	lda (addr0),y
	beq @end
	iny
	cpy #COL_END-COL_START
	bcc @l0
	.byte $1c ;skw
@end:   inc @done
@draw:	sty text::len
	ldx #<addr0
	ldy #>addr0
	lda @row
	jsr text::puts

	lda addr0
	clc
	adc #COL_END-COL_START
	sta addr0
	lda #$00
	adc addr0+1
	sta addr0+1

	lda @done
	beq @0
	inc @row
	lda @row
	cmp #ROW_STOP
	bcc @l0
@0:	rts
.endproc

.endscope

