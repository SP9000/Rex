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
	jsr gui::drawinv
	rts
.endproc

; rock is a test "thing"
rock:
	.word 1 ; id
	.word gfx::rock
	;.word thing::usetake
	.word rock_desc

rockname: .byte "rock",0
rock_desc:
	.byte rock_desc_len, "a smooth purple pebble",0
rock_desc_len=*-rock_desc

testmsg: .byte "hello world ",0
