.include "math.inc"
.include "macros.inc"
.include "room.inc"
.include "zeropage.inc"

.CODE

MAX_ITEMS=64

.export __inventory_len
__inventory_len:
len:   .byte 0  ; # of items in player's inventory
.export __inventory_items
__inventory_items:
items: .res 2*MAX_ITEMS ; the items in the player's inventory

; table of sprite addresses for each item. Each entry represents an address
; greater than the one that precedes it
spritestable: .res 2*MAX_ITEMS

; persistent buffer to store sprite graphic data
spritesbuffer: .res 32*MAX_ITEMS

;--------------------------------------
; add adds the item of the ID (YX) to the player's inventory.
; this routine copies the sprite data for that item to a persistent location.
.export __inventory_add
.proc __inventory_add
@sprite=zp::tmp0
@dst=zp::tmp2
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

	; get the address to copy the sprite data to
	lda spritestable+2,x
	sta @dst
	lda spritestable+3,x
	sta @dst+1

	jsr room::gethandle
	cmp #$ff
	bne @copyfromroom

	; TODO: load item from disk
	rts

@copyfromroom:
	jsr room::getsprite
	stx @sprite
	sty @sprite+1
	ldx len
	ldy #$00
	lda (@sprite),y
	incw @sprite
	tax
	lda (@sprite),y
	incw @sprite
	tay
	jsr m::mul8
	asl	; *2 (alpha + color)

	; copy the graphic data
	tay
@l0:	lda (@sprite),y
	sta (@dst),y
	dey
	bpl @l0
	pha

	; compute start address of next sprite that is loaded
	lda len
	asl
	tax
	pla
	adc spritestable,x
	sta spritestable+2,x
	lda spritestable+1,x
	adc #$00
	sta spritestable+3,x
@done:  rts
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
