.include "handlers.inc"
.include "zeropage.inc"

REPEAT_TMR=60

.CODE
;--------------------------------------
.export __key_handle
.proc __key_handle
	jsr __key_get
	beq @done
	cmp #$51
	bne @chkexits
	on_space
	rts

@chkexits:
	cmp #$72	; E
	bne :+
	jmp room::east

:	cmp #$22	; W
	bne :+
	jmp room::west

:	cmp #$62	; S
	bne :+
	jmp room::south

:	cmp #$45	; N
	bne @done
	jmp room::north

@done:	rts
.endproc

repeat: .byte REPEAT_TMR

;--------------------------------------
; read one key from the keyboard. code (col bit # << 4) + row bit #) returned in .A
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

	ldy #$01
@l0:	lda @col
	eor #$ff
	sta $9120
	lda #$01
	sta @row

	ldx #$01
@l1:	lda $9121	; read port B
	and @row
	beq @found
	inx
	asl @row
	bne @l1
	iny
	asl @col
	bne @l0
@notfound:
	lda #$00
	cli
	rts
@found:
	stx @row
	tya
	asl
	asl
	asl
	asl
	adc @row
	cli
	rts
.endproc
