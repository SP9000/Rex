.include "app_sprites.inc"

;--------------------------------------
;joystick handlers:
;joystick handlers are small user-defined routines executed when the handler's
;corresponding button is pressed.  Handlers cannot exceed the size of the range
;of a forward relative branch (127 bytes).
;The .X and .Y registers can be clobbered without issue, but you must save and
;restore .A if you need to use it. 
;Simply do a "pha" at the beginning of your handler and a "pla" at the end if 
;this is the case.
;
;------------------
;put your left-button handler here
.macro on_left
        ldx app::cursor
        beq :+
        dec app::cursor
        inc app::cursor+4
:
.endmacro 
;------------------
;put your right-button handler here
.macro on_right
        ldx app::cursor
        cpx #160-9
        bcs :+
        inc app::cursor
        inc app::cursor+4
:
.endmacro 
;------------------
;put your up-button handler here
.macro on_up
        ldx app::cursor+1
        beq :+
        dec app::cursor+1 
        inc app::cursor+4
:
.endmacro 
;------------------
;put your down-button handler here
.macro on_down
        ldx app::cursor+1
        cpx #192-9
        bcs :+
        inc app::cursor+1
        inc app::cursor+4
:
.endmacro
;------------------
;put your fire-button handler here
.macro on_fire
.endmacro
