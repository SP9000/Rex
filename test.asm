.include "app_sprites.inc"
.include "bitmap.inc"
.include "gui.inc"
.include "inventory.inc"
.include "irq.inc"
.include "joystick.inc"
.include "text.inc"
.include "sprite.inc"
.include "thing.inc"

.export test
.proc test
	ldx #<testmsg
	ldy #>testmsg
	jsr gui::txt
	ldx #<rock
	ldy #>rock
	jsr thing::add
	ldx #<rock
	ldy #>rock
	jsr inv::add
	ldx #<rock
	ldy #>rock
	jsr inv::add
	jsr gui::drawinv
	rts
.endproc

; rock is a test "thing"
rock:
	.word 1 ; id
	.word app::rock
	.word thing::usetake
	.word rock_desc
rock_desc:
	.byte rock_desc_len, "a smooth purple pebble"
rock_desc_len=*-rock_desc

testmsg: .byte "hello world ",0
