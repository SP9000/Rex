.include "bitmap.inc"
.include "pen.inc"
.include "zeropage.inc"

SCREEN_START_ADDR = ($1100 + ($c0*4) + 16)

;--------------------------------------
.export __fx_fadeout
.proc __fx_fadeout
@x = zp::tmp2
@y1 = zp::tmp3
@y2 = zp::tmp4
	lda #16
	sta @y1
	lda #112+16
	sta @y2
	lda #4*8
	sta @x
	lda #4*8+96
	sta zp::arg1

@l0:
	; top line
	lda @x
	sta zp::arg0
	lda @y1
	sta zp::arg2
	jsr pen::hline

	; bottom line
	lda @x
	sta zp::arg0
	lda @y2
	sta zp::arg2
	jsr pen::hline

	inc @y1
	dec @y2
	lda @y1
	cmp #112/2+17
	bne @l0

	rts
.endproc

;--------------------------------------
.export __fx_fadein
.proc __fx_fadein
@x = zp::tmp4
@y1 = zp::tmp5
@y2 = zp::tmp6
	lda #112/2
	sta @y1
	lda #112/2
	sta @y2
	lda #$00
	sta @x
	lda #96
	sta zp::arg1

@l0:
	; top line
	lda @x
	sta zp::arg0
	lda @y1
	sta zp::arg2
	jsr pen::restorehline

	; bottom line
	lda @x
	sta zp::arg0
	lda @y2
	sta zp::arg2
	jsr pen::restorehline

	inc @y2
	dec @y1
	bpl @l0

	rts
.endproc

;--------------------------------------
; blink flashes the screen .A times at the speed given in .X
.export __fx_blink
.proc __fx_blink
@times=zp::tmp0
@spd=zp::tmp0
	sta @times
	stx @spd
	lda #$20
@l0:	lda #$08
	eor $900f
	sta $900f

	lda #$20
	ldx @spd
@l1:	cmp $9004
	bne *-3
	dex
	bpl @l1
	dec @times
	bpl @l0

	; always end on non-inverted colors
	lda $900f
	and #$f7
	sta $900f
	rts
.endproc

;--------------------------------------
; flashes the screen ($900f) with the color in .A
; blinks .X times where each is delayed by a delay in .Y
; flash
.export __fx_flash
.proc __fx_flash
@dly=zp::tmp0
@savecolor=zp::tmp1
@blinkcolor=zp::tmp2
	sta @blinkcolor
	lda $900f
	sta @savecolor
	sty @dly

@l0:	ldy @dly
@l1:	lda @blinkcolor
	sta $900f

	lda #$01
	cmp $9004
	bne *-3

	lda @savecolor
	sta $900f

	lda #$00
	cmp $9004
	bne *-3

	dey
	bpl @l1
	dex
	bpl @l0

	lda @savecolor
	sta $900f
	rts
.endproc
