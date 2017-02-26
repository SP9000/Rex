.struct Room 
	items .byte ;# of sprites in the room
	exits .byte ;# of exits
	desc  .byte ;a description displayed upon entering the room
.endstruct

.import __room_load

.scope room
	load = __room_load ; loads the room at address (YX)
.endscope
