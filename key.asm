.include "handlers.inc"
.include "zeropage.inc"

REPEAT_TMR=60

.CODE
;--------------------------------------
.export __key_handle
.proc __key_handle
	jsr __key_get
	beq @done
	cmp #$11
	bne @done
	on_space
@done:	rts
.endproc

repeat: .byte REPEAT_TMR

;--------------------------------------
; read one key from the keyboard. code (row | col) returned in .A
.export __key_get
.proc __key_get
@row=zp::tmp0
@col=zp::tmp1
	sei
	lda #$00
	sta $9123	; port A output
	lda #$ff
	sta $9122	; port B input

	lda #$01
	sta @col
@l0:	lda @col
	eor #$ff
	sta $9120
	lda #$01
	sta @row
@l1:	lda $9121	; read port B
	and @row
	beq @found
	asl @row
	bne @l1
	asl @col
	bne @l0
@notfound:
	lda #$00
	cli
	rts
@found:
	lda @row
	ora @col
	cli
	rts
.endproc
