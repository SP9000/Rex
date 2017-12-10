.include "zeropage.inc"

.CODE

.export __inventory_len
__inventory_len:
len:   .byte 0  ; # of items in player's inventory
.export __inventory_items
__inventory_items:
items: .res 256 ; the items in the player's inventory

;--------------------------------------
; add adds the item of the ID (YX) to the player's inventory.
.export __inventory_add
.proc __inventory_add
	txa
	pha
	lda len
	asl
	tax
	pla
	sta items,x
	tya
	sta items+1,x
	inc len
	rts
.endproc

;--------------------------------------
; remove removes the item of the ID (YX) from the player's inventory.
.export __inventory_remove
.proc __inventory_remove
@item = zp::tmp0
@len2 = zp::tmp2
@itemhi = zp::tmp3
	lda #<items
	sta @item
	lda #>items
	sta @item+1
	lda len
	asl
	sta @len2
	
	sty @itemhi
	ldy #$00
@l0:	lda @itemhi
	cmp (@item),y
	bne @next
	txa
	iny
	cmp (@item),y
	beq @found

	dey
@next:	iny
	iny
	cpy @len2
	bcc @l0
	rts

@found:	lda items+2,y
	sta items,y
	lda items+3,y
	sta items+1,y
	iny
	iny
	cpy @len2
	bcc @found
	
	dec len
	rts
.endproc
