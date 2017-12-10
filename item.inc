.include "sprite.inc"

.import __item_additem
.import __item_take
.import __item_use
.import __item_discard
.import __item_len
.import __item_list

.struct Item
	sprite .tag Sprite ; the sprite data for the item
	use    .word       ; use handler - in: (XY)=target of operation
	take   .word       ; take handler
	name   .word       ; a string containing the item's name
	desc   .word       ; a string description of the item
.endstruct

.scope item
	additem = __item_additem
	take    = __item_take
	use     = __item_use
	discard = __item_discard
.endscope
