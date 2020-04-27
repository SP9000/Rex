.import __room_load
.import __room_remove
.import __room_gethandle 
.import __room_getsprite
.import __room_getdesc
.import __room_update

.import __room_look
.import __room_use

.import __room_east
.import __room_west
.import __room_north
.import __room_south

.scope room
	load = __room_load ; loads the room at address (YX)
	remove = __room_remove ; remove the thing with the given ID (in .A)
	update = __room_update
	gethandle = __room_gethandle
	getsprite = __room_getsprite
	getdesc = __room_getdesc
	look = __room_look
	use = __room_use

	north = __room_north
	south = __room_south
	east  = __room_east
	west  = __room_west
.endscope
