.include "app.inc"
.include "app_sprites.inc"
.include "fx.inc"
.include "room.inc"
.include "sprite.inc"

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
	ldx #-1
	ldy #0
	jsr app::movecur
.endmacro 

;------------------
;put your right-button handler here
.macro on_right
	ldx #1
	ldy #0
	jsr app::movecur
.endmacro 

;------------------
;put your up-button handler here
.macro on_up
	ldx #0
	ldy #-1
	jsr app::movecur
.endmacro 

;------------------
;put your down-button handler here
.macro on_down
	ldx #0
	ldy #1
	jsr app::movecur
.endmacro

;------------------
;put your fire-button handler here
.macro on_fire
.local @do
.local @done
	lda action
	cmp #ACTION_USE
	bne :+
	jmp room::use
:	cmp #ACTION_LOOK
	bne @done
	jmp room::look
@done:	rts
.endmacro

;------------------
;put your 'SPACE' button handler here
.macro on_space
	rts
.endmacro
