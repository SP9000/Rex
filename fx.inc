.import __fx_blink
.import __fx_fadeout
.import __fx_fadein
.import __fx_vshake
.import __fx_vshakeblink

.scope fx
	fadeout = __fx_fadeout
	fadein  = __fx_fadein
	blink   = __fx_blink
	shake   = __fx_vshake
	vshakeblink = __fx_vshakeblink
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

.macro vshake times, amp
	ldx times
	ldy amp
	jsr __fx_vshake
.endmacro

.macro vshakeblink times, amp, color
	ldx times
	ldy amp
	lda color
	jsr __fx_vshakeblink
.endmacro
