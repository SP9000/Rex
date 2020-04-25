.import __fx_blink
.import __fx_fadeout
.import __fx_fadein

.scope fx
	fadeout = __fx_fadeout
	fadein  = __fx_fadein
	blink   = __fx_blink
.endscope

.macro blink color, times, delay
	lda color
	ldx times
	ldy delay
	jsr __fx_blink
.endmacro

.macro blink2 color
	lda color
	ldx #4
	ldy #10
	jsr __fx_blink
.endmacro
