.include "zeropage.inc"

.import __sprite_on
.import __sprite_off
.import __sprite_set
.import __sprite_w
.import __sprite_h
.import __sprite_testsprite
.import __sprite_load
.import __sprite_draw
.import __sprite_dim
.import __sprite_pos
.import __sprite_size

; There are two types of sprite routines: standard and fast. 
; The standard routines back up and restore the background prior to rendering.
; The fast routines do no such backup and only work with empty backgrounds.
.scope sprite
	xpos       = zp::tmp2
	ypos       = zp::tmp3
	w          = zp::tmp4
	h          = zp::tmp5
	flags      = zp::tmp6
	cdata      = zp::tmp7
	amask      = zp::tmp9
	dst        = zp::tmpb
	next_col   = zp::tmpd
	next_alpha = zp::tmpe
	alpha      = zp::tmpf
	bakup      = zp::tmp10

	load            = __sprite_load
        on              = __sprite_on       ; turn on the sprite in (YX)
	draw            = __sprite_draw     ; draw the sprite already loaded with "load"
        off             = __sprite_off      ; turn off the sprite in (YX) 
	set             = __sprite_set      ; sets the sprite to the coordinates (.X,.Y)
        testsprite      = __sprite_testsprite
	dim             = __sprite_dim       ; get the dimensions of the sprite
	pos             = __sprite_pos       ; get the position of sprite
	size	        = __sprite_size	     ; get size of the sprite data in bytes
.endscope
