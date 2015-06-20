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
.import __sprite_testsprite

; There are two types of sprite routines: standard and fast. 
; The standard routines back up and restore the background prior to rendering.
; The fast routines do no such backup and only work with empty backgrounds.
.scope sprite
        on              = __sprite_on       ; turn on the sprite in (YX)
        on_f            = __sprite_on_f     ; turn off the sprite in (YX) fast
        off             = __sprite_off      ; turn off the sprite in (YX) 
        off_f           = __sprite_off_f    ; turn off the sprite in (YX) fast
        testsprite      = __sprite_testsprite
.endscope
