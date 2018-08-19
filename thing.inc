.import __thing_add
.import __thing_handle
.import __thing_num
.import __thing_table
.import __thing_use
.import __thing_usetake

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


.scope thing
	handle = __thing_handle
	use = __thing_use

	usetake = __thing_usetake
	table = __thing_table ; a table of all the things in the room

	add = __thing_add
	num = __thing_num
.endscope
