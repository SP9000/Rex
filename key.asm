.include "handlers.inc"
.include "zeropage.inc"

.CODE
;--------------------------------------
.export __key_handle
.proc __key_handle
	rts
	on_space
	rts
.endproc

;--------------------------------------
; read one key from the keyboard. code (row | col) returned in .A
.export __key_get
.proc __key_get
@row=zp::tmp0
@col=zp::tmp1
	sei
	lda #$ff
	sta $9113	; port A output
	lda #$00
	sta $9112	; port B input

	lda #$01
	sta @col
@l0:	lda @col
	sta $9111
	lda #$01
	sta @row
@l1:	lda $9110	; read port B
	and @row
	beq @found
	asl @row
	bne @l1
	asl @col
	bne @l0
@notfound:
	cli
	rts
@found:
	lda @row
	ora @col
	cli
	rts
.endproc

