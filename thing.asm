.include "zeropage.inc"
.include "sprite.inc"
.include "app_sprites.inc"

thing = zp::tmp0
desc = zp::tmp2
dat = zp::tmp4
sprite = zp::tmp6

.struct Thing
	id     .word ; unique identifier for the thing.
	sprite .word ; sprite identifier
	use    .word ; address of use callback.
		     ; the use callback contains the thing being used in
		     ; (zp::tmp0) and the ID of the thing that the thing is
		     ; being used on in .X.
	desc   .word ; address of length-prefixed description of the thing.
	data   .word ; address of thing specific data
.endstruct

.struct DoorData
	locked .word ; if 0, door is unlocked otherwise the ID of the key
.endstruct

;--------------------------------------
; use
.export __thing_use
.proc __thing_use
@thing = zp::tmp0
	sta zp::tmp0
	asl
	asl
	adc zp::tmp0
	tay

	lda __thing_table,y
	sta @thing
	lda __thing_table+1,y
	sta @thing+1

	ldy #$02
	lda (@thing),y
	sta sprite
	iny
	lda (@thing),y
	sta sprite+1

	iny
	lda (@thing),y
	sta @handle
	iny
	lda (@thing),y
	sta @handle+1
	
	iny
	lda (@thing),y
	sta desc
	iny
	lda (@thing),y
	sta desc+1
	
	iny
	lda (@thing),y
	sta dat
	iny
	lda (@thing),y
	sta dat+1

@handle=*+1
	jsr $ffff
	rts
.endproc

;--------------------------------------
; usedoor is a convienience handler for things that behave like a door.
.export __thing_usedoor
.proc __thing_usedoor
@keylo=zp::tmp8
@keyhi=zp::tmp9
	stx @keylo
	sty @keyhi

	ldy #DoorData::locked
	lda (dat),y
	cmp #$00
	bne @key

@go:	; TODO: GO through the door
	rts
	
@key:	cpx @keylo
	bne @disallow
	cpy @keyhi
	beq @allow
@disallow:
	rts
	
@allow:	lda #$00
	ldy #DoorData::locked
	sta (dat),y
	iny
	sta (dat),y

	rts
.endproc

;--------------------------------------
; usekey is a convienience handler for things that behave like a takeable
; item.
.export __thing_usetake
.proc __thing_usetake
	; TODO: add to inventory and remove from world.
	rts
.endproc

;--------------------------------------
; add adds the thing at (YX) to the thing table.
.export __thing_add
.proc __thing_add
	stx zp::tmp0
	sty zp::tmp0+1
	lda __thing_num
	asl
	tax

	lda zp::tmp0
	sta __thing_table,x
	tya
	sta __thing_table+1,x

	ldy #$02
	lda (zp::tmp0),y
	tax
	iny
	lda (zp::tmp0),y
	tay
	
	ldx #<app::rock
	ldy #>app::rock
	jsr sprite::on
	
	rts
.endproc

;--------------------------------------
.export __thing_table
__thing_table:
.res 256

.export __thing_num
__thing_num:
.byte 0
