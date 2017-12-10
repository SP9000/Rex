.include "zeropage.inc"

.struct Sprite 
        xpos    .byte   ;the x coordinate
        ypos    .byte   ;the y coordinate
        w       .byte   ;the width in characters
        h       .byte   ;the height in pixels
        flags   .byte   ;user flags - unused
        data    .byte   ;data - contains w*h bytes of color data followed
                        ;by w*h bytes for the alpha mask
.endstruct

.import __sprite_on
.import __sprite_on_f
.import __sprite_off
.import __sprite_off_f
.import __sprite_setx
.import __sprite_sety
.import __sprite_w
.import __sprite_h
.import __sprite_testsprite
.import __sprite_load
.import __sprite_draw

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
        on_f            = __sprite_on_f     ; turn off the sprite in (YX) fast
        off             = __sprite_off      ; turn off the sprite in (YX) 
        off_f           = __sprite_off_f    ; turn off the sprite in (YX) fast
	setx            = __sprite_setx     ; sets x-pos of sprite in (YX) to A
	sety            = __sprite_sety     ; sets y-pos of sprite in (YX) to A
        testsprite      = __sprite_testsprite
.endscope
