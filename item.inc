.import __item_additem
.import __item_take
.import __item_use
.import __item_discard
.import __item_len
.import __item_list

.struct Item
	sprite .byte
	take   .word
	use    .word
	desc   .byte
.endstruct

.scope item
	additem = __item_additem
	take    = __item_take
	use     = __item_take
	discard = __item_discard

	len     = __item_len
	list    = __item_list
.endscope
