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
	ldx #<rock
	ldy #>rock
	;jsr room::add
	ldx #<rock
	ldy #>rock
	jsr inv::add
	ldx #<rock
	ldy #>rock
	jsr inv::add
	;jsr gui::drawinv
	rts
.endproc

; rock is a test "thing"
rock:
	.word 1 ; id
	.word gfx::rock
	;.word thing::usetake
	.word rock_desc
rock_desc:
	.byte rock_desc_len, "a smooth purple pebble",0
rock_desc_len=*-rock_desc

testmsg: .byte "hello world ",0
