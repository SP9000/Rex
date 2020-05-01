.include "zeropage.inc"

.export __sfx_playing
__sfx_playing: .byte 0
playcnt: .byte 0
update: .word 0
voice_backup: .res 5

;--------------------------------------
; update updates a currently playing sound effect (if there is one)
;
.export __sfx_update
.proc __sfx_update
	lda __sfx_playing
	beq @done
	lda playcnt
	bne @update

@sfx_done:
	; restore voices
	ldx #$04
@l0:	lda voice_backup,x
	sta $900a,x
	dex
	bpl @l0
	inx
	stx __sfx_playing
@done:	rts

@update:
	dec playcnt
	jmp (update)
.endproc

;--------------------------------------
; plays the sound effect in (YX). FX have two vectors
; .word setup
; .word update
.export __sfx_play
.proc __sfx_play
@sfx=zp::tmp0
	stx @init
	sty @init+1
	stx @sfx
	sty @sfx+1

	; store the update vector
	ldy #$02
	lda (@sfx),y
	sta update
	iny
	lda (@sfx),y
	sta update+1

	; backup voices
	ldx #$04
@l0:	lda $900a,x
	sta voice_backup,x
	dex
	bpl @l0

	; run init code for fx
@init=*+1
	jmp ($ff00)
.endproc

;--------------------------------------
.proc hit_start
	lda #$30
	sta playcnt
	lda #$93
	sta $900d
	lda #$07
	sta $900e
	inc __sfx_playing
	rts
.endproc

;--------------------------------------
.proc hit_update
	rts
.endproc

;--------------------------------------
.export __sfx_hit
.proc __sfx_hit
	ldx #<@hit
	ldy #>@hit
	jmp __sfx_play
@hit:
.word hit_start
.word hit_update
.endproc
