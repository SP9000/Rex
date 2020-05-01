;--------------------------------------
; Macros to help scripting 
;--------------------------------------
.ifndef SCRIPT_INC
SCRIPT_INC = 1
.include "base.inc"
.include "constants.inc"

;--------------------------------------
; ontake handles the action of TAKE'ing the item by executing func if the
; action is TAKE
.macro ontake func
.local @no
	lda action
	cmp #ACTION_TAKE
	bne @no
	lda item
	jsr func
@no:
.endmacro

;--------------------------------------
; onuse handles the action of USE'ing the item by executing func if the
; action is USE
.macro onuse func
.local @no
	lda action
	cmp #ACTION_USE
	bne @no
	lda item
	jsr func
@no:
.endmacro

;--------------------------------------
; check executes the statement between check and endcheck if the cursor is
; within the given bounding box
; coordinates are given relative to the upper-left corner of the sprite
; if the cursor is within the given box, func is executed
.macro check x, y, w, h, func
.local @no
	lda relx
	cmp x
	bcc @no
	cmp w
	bcs @no

	lda rely
	cmp y
	bcc @no
	cmp h
	bcs @no
	jsr func
@no:
.endmacro

.endif
