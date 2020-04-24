.import __inventory_add
.import __inventory_remove
.import __inventory_items
.import __inventory_len
.import __inventory_itemname
.import __inventory_selection	; the index of the selected #
.import __inventory_select

.scope inv
	items = __inventory_items
	len = __inventory_len
	add = __inventory_add
	remove = __inventory_remove
	itemname = __inventory_itemname
	selection = __inventory_selection
	select = __inventory_select
.endscope

.macro additem id, name
	.if .match( .left( 1, {name} ), # )
		lda #<(.right( .tcount( {name} )-1, {name} ))
		sta zp::arg0
		lda #>(.right( .tcount( {name} )-1, {name} ))
		sta zp::arg1
	.else
		lda name
		sta zp::arg0
		lda 1+(name)
		sta zp::arg1
	.endif
	lda #id
	jsr inv::add
.endmacro

