.include "zeropage.inc"
.include "sprite.inc"
.include "app.inc"

.CODE

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
; use runs the handler for the thing given in .A
.export __thing_use
.proc __thing_use
@thing = zp::tmp0
	asl
	tay
	lda __thing_table,y
	sta @thing
	lda __thing_table+1,y
	sta @thing+1

	ldy #Thing::sprite
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
	jmp $ffff
.endproc

;--------------------------------------
; handle runs the handler for the thing at the coordinates given in (.X,.Y) or,
; if there is nothing at that position, does nothing.
.export __thing_handle
.proc __thing_handle
@sprite=zp::tmp0
@xpos=zp::tmp2
@ypos=zp::tmp3
@xstop=zp::tmp4
@ystop=zp::tmp5
@w=zp::tmp4
@h=zp::tmp5
@i=zp::tmp6
@thing=zp::tmp7
	lda #$00
	sta @i
@l0:	lda @i
	asl
	tay
	lda __thing_table,y
	sta @thing
	lda __thing_table+1,y
	sta @thing+1
	ldy #Thing::sprite
	lda (@thing),y
	sta @sprite
	iny
	lda (@thing),y
	sta @sprite+1

	ldy #Sprite::ypos
	lda (@sprite),y
	sta @ypos
	ldy #Sprite::xpos
	lda (@sprite),y
	sta @xpos
	ldy #Sprite::w
	lda (@sprite),y
	asl
	asl
	asl
	adc @xpos
	sta @xstop
	ldy #Sprite::h
	lda (@sprite),y
	adc @ypos
	sta @ystop

	jsr app::curx
	cmp @xpos
	bcc @next
	cmp @xstop
	bcs @next

	jsr app::cury
	cmp @ypos
	bcc @next
	cmp @ystop
	bcs @next
	lda @i
	jmp __thing_use

@next:  inc @i
	lda @i
	cmp __thing_num
	bcc @l0
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
; usetake is a convienience handler for things that behave like a takeable
; item.
.export __thing_usetake
.proc __thing_usetake
	; TODO: add to inventory and remove from world.
	inc $900f
	jmp *-3
	rts
.endproc

;--------------------------------------
; add adds the thing at (YX) to the thing table.
.export __thing_add
.proc __thing_add
@t=zp::tmp0
	stx @t
	sty @t+1
	lda __thing_num
	asl
	tax

	lda @t
	sta __thing_table,x
	tya
	sta __thing_table+1,x

	; draw sprite
	ldy #$02
	lda (@t),y
	tax
	iny
	lda (@t),y
	tay
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
