.import __gui_drawinv
.import __gui_input
.import __gui_textinput
.import __gui_name
.import __gui_txt
.import __gui_clrtxt
.import __gui_wrect
.import __gui_action

.struct TextRegion
	xpos .byte
	ypos .byte
	w .byte
	h .byte
.endstruct

.scope gui
	name = __gui_name ;display the message in (YX)
	txt = __gui_txt ;display the message in (YX)
	clrtxt = __gui_clrtxt ; clear the text area
	drawinv = __gui_drawinv	; draw the player's inventory
	input   = __gui_input   ; get user input and return string in (YX)
	textinput = __gui_textinput ; display text in (YX) and get user input
	wrect = __gui_wrect ; draw a white rectangle from (.X,.Y) to (zp::tmp0,zp::tmp1)
	action = __gui_action
.endscope
