.import __room_load
.import __room_gethandle 
.import __room_getsprite
.import __room_getdesc

.import __room_look
.import __room_use

.scope room
	load = __room_load ; loads the room at address (YX)
	gethandle = __room_gethandle
	getsprite = __room_getsprite
	getdesc = __room_getdesc
	look = __room_look
	use = __room_use
.endscope
