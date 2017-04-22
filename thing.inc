.import __thing_use
.import __thing_table
.import __thing_usetake
.import __thing_add
.import __thing_num

.scope thing
	use = __thing_use     ; uses the thing in (YX) on the one in (zp::tmp0)

	usetake = __thing_usetake
	table = __thing_table ; a table of all the things in the room

	add = __thing_add
	num = __thing_num
.endscope
