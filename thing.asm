.include "app.inc"
.include "gui.inc"
.include "sprite.inc"
.include "zeropage.inc"

.CODE

thing = zp::tmp0
desc = zp::tmp2
dat = zp::tmp4
sprite = zp::tmp6
handler = zp::tmp8

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
.proc readin
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
	sta handler
	iny
	lda (@thing),y
	sta handler+1

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
	rts
.endproc

;--------------------------------------
; use runs the handler for the thing given in .A
.export __thing_use
.proc __thing_use
@thing = zp::tmp0
	jsr readin
	ldx handler
	ldy handler+1
	stx @handle
	sty @handle+1
@handle=*+1
	jmp $ffff
.endproc

;--------------------------------------
; lookat prints the description.
.proc lookat
	ldx desc
	ldy desc+1
	inx
	bne :+
	iny
:	jsr gui::txt
	rts
.endproc

;--------------------------------------
; look prints the description of the selected thing.
.export __thing_look
__thing_look:
	lda #$01
	.byte $2c
;--------------------------------------
; handle runs the handler for the thing at the coordinates given in (.X,.Y) or,
; if there is nothing at that position, does nothing.
.export __thing_handle
.proc __thing_handle
@xpos=zp::tmpa
@ypos=zp::tmpb
@xstop=zp::tmpc
@ystop=zp::tmpd
@i=zp::tmpe
@use_or_look=zp::tmpf
@thing=zp::tmp10
	lda #$00
	sta @use_or_look
	lda #$00
	sta @i
@l0:	lda @i
	cmp __thing_num
	bcc :+
	rts
:	jsr readin

	ldx sprite
	ldy sprite+1
	jsr sprite::pos
	stx @xpos
	sty @ypos

	ldx sprite
	ldy sprite+1
	jsr sprite::dim
	clc
	adc @ypos
	sta @ystop

	txa
	asl
	asl
	asl
	adc @xpos
	sta @xstop

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
	ldx @use_or_look	; do we want to LOOK or USE the selected thing?
	bne @look

@use:   jmp (handler)
@look:  jmp lookat

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

	inc __thing_num
	rts
.endproc

;--------------------------------------
.export __thing_table
__thing_table:
.res 256

.export __thing_num
__thing_num:
.byte 0
