.import __gui_drawinv
.import __gui_input
.import __gui_textinput
.import __gui_txt
.import __gui_wrect

.struct TextRegion
	xpos .byte
	ypos .byte
	w .byte
	h .byte
.endstruct

.scope gui
	txt = __gui_txt ;display the message in (YX)
	drawinv = __gui_drawinv	; draw the player's inventory
	input   = __gui_input   ; get user input and return string in (YX)
	textinput = __gui_textinput ; display text in (YX) and get user input
	wrect = __gui_wrect ; draw a white rectangle from (.X,.Y) to (zp::tmp0,zp::tmp1)
.endscope
