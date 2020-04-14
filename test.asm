.include "app_sprites.inc"
.include "bitmap.inc"
.include "gui.inc"
.include "inventory.inc"
.include "irq.inc"
.include "joystick.inc"
.include "text.inc"
.include "sprite.inc"
.CODE

.export test
.proc test
	additem 1, #rockname
	additem 2, #torchname
	additem 3, #slingname
	additem 4, #ladelname
	additem 5, #flutename
	additem 6, #tomename
	additem 7, #ashesname
	rts
.endproc

; rock is a test "thing"
rock:
	.word 1 ; id
	.word gfx::rock
	;.word thing::usetake
	.word rock_desc

tomename: .byte "tome",0
ashesname: .byte "ashes",0
torchname: .byte "torch",0
slingname: .byte "sling",0
flutename: .byte "flute",0
ladelname: .byte "ladel",0
rockname: .byte "rock",0
rock_desc:
	.byte rock_desc_len, "a smooth purple pebble",0
rock_desc_len=*-rock_desc


testmsg: .byte "hello world ",0
