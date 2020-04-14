.include "gui.inc"
.include "macros.inc"
.include "math.inc"
.include "room.inc"
.include "zeropage.inc"

.CODE

MAX_ITEMS=64
ITEM_NAME_LEN=16

.export __inventory_len
__inventory_len:
len:   .byte 0  ; # of items in player's inventory

.export __inventory_items
__inventory_items:
items: .res MAX_ITEMS ; the ID's of items in the player's inventory
namebuff: .res MAX_ITEMS*ITEM_NAME_LEN

.export __inventory_selection
__inventory_selection: .byte 0

;--------------------------------------
; add adds the item of the ID in .A to the player's inventory.
; the name is given in zp::arg0 and the description in zp::arg1
; this routine copies the sprite data for that item to a persistent location.
.export __inventory_add
.proc __inventory_add
@name=zp::arg0
@desc=zp::arg2
@dst=zp::tmp0
	pha
	ldy #$00
@l0:	lda items,y
	beq :+
	iny
	cpy #MAX_ITEMS
	bcc @l0
	pla
	rts	; inventory is full

:	pla
	sta items,y

	lda #$00
	sta @dst+1
	tya
	; *16, get name address
	asl
	asl
	asl
	rol @dst+1

	adc #<namebuff
	sta @dst
	lda #>namebuff
	adc @dst+1
	sta @dst+1

	ldy #$ff
@l1:	iny
	lda (@name),y
	sta (@dst),y
	bne @l1

	inc __inventory_len
	rts
.endproc

;--------------------------------------
; remove removes the item of the ID (YX) from the player's inventory.
.export __inventory_remove
.proc __inventory_remove
@dst=zp::tmp0
	asl
	tay
	lda #$00
	sta items,y

	lda #$00
	sta @dst
	tya
	; *16, get name address
	asl
	asl
	asl
	rol @dst
	asl
	rol @dst

	lda #$00
	ldy #ITEM_NAME_LEN-1
@l0:	sta (@dst),y
	dey
	bpl @l0

	dec __inventory_len
	rts
.endproc

;--------------------------------------
.export __inventory_itemname
.proc __inventory_itemname
@msb=zp::tmpa
	ldx #$00
	stx @msb+1
	asl
	asl
	asl
	rol @msb+1
	adc #<namebuff
	tax
	lda @msb+1
	adc #>namebuff
	tay
	rts
.endproc

;--------------------------------------
.export __inventory_select
.proc __inventory_select
	cmp __inventory_len
	bcc :+
	rts
:	sta __inventory_selection
	jmp gui::drawinv
.endproc
