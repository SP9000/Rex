.include "app_sprites.inc"
.include "bitmap.inc"
.include "irq.inc"
.include "joystick.inc"
.include "text.inc"
.include "sprite.inc"
.include "thing.inc"

.export test
.proc test
	ldx #<rock
	ldy #>rock
	jsr thing::add
	rts
.endproc

rock:
	.word 1 ; id
	.word app::rock
	.word thing::usetake
	.word rock_desc
rock_desc:
	.byte rock_desc_len, "a smooth purple pebble"
rock_desc_len=*-rock_desc
