.include "app.inc"
.include "file.inc"
.include "fx.inc"
.include "gui.inc"
.include "macros.inc"
.include "math.inc"
.include "memory.inc"
.include "sprite.inc"
.include "text.inc"
.include "types.inc"
.include "zeropage.inc"
.CODE

ROOM_WIDTH = 96/8
ROOM_HEIGHT = 112

MAX_THINGS = 8
NUM_EXITS=6

;--------------------------------------
numrooms: .byt 0


spritetable: .res MAX_THINGS*2
idstable: .res MAX_THINGS*2
nametable: .res MAX_THINGS*2
desctable: .res MAX_THINGS*2
usetable: .res MAX_THINGS*2
numthings: .byte 0

name: .word 0
description: .word 0

; the addresses for room names for N,S,E,W,U,D
exits: .res 2*6

;--------------------------------------
; addthing adds the thing in (YX) to the room
; 0-1 sprite address
; 2-3 name address
; 4-5 description address
; 6-7 handler (use) address
.proc __room_addthing
@t=zp::tmp0
	stx @t
	sty @t+1

	lda numthings
	asl
	tax

	ldy #$00
	lda (@t),y
	sta spritetable,x
	iny
	lda (@t),y
	sta spritetable+1,x

	iny
	lda (@t),y
	sta nametable,x
	iny
	lda (@t),y
	sta nametable+1,x

	iny
	lda (@t),y
	sta desctable,x
	iny
	lda (@t),y
	sta desctable+1,x

	iny
	lda (@t),y
	sta usetable,x
	iny
	lda (@t),y
	sta usetable+1,x
	rts
.endproc

;--------------------------------------
; gethandle returns the room handle for the thing of the ID given in (YX)
; if the thing is not present in the room, returns $ff. The result is given in .A
; Use the handle returned to get the sprite, description, etc. via the other
; getters.
.export __room_gethandle
.proc __room_gethandle
	stx @lo
	sty @hi

	tya
	ldy #$00
	ldx numthings
@l0:
@lo=*+1
	lda #$00
	cmp idstable,y
	bne @next
@hi=*+1
	lda #$00
	cmp idstable+1,y
	bne @next
@found:
	tya
	lsr
	rts

@next: 	iny
	iny
	dex
	bne @l0
@notfound:
	lda #$ff
	rts
.endproc

;--------------------------------------
; getsprite returns the sprite for the thing from the given room handle in (YX).
.export __room_getsprite
.proc __room_getsprite
	tax
	lda spritetable+1,x
	tay
	lda spritetable,x
	tax
	rts
.endproc

;--------------------------------------
; getdesc returns the description for the thing from the given room handle in (YX)
.export __room_getdesc
.proc __room_getdesc
	tax
	lda desctable+1,x
	tay
	lda desctable,x
	tax
	rts
.endproc

;--------------------------------------
; loads a filename from the given length prefixed string
.proc load_lpstr
	stx $f0
	sty $f1
	ldy #$00
	lda ($f0),y
	ldx $f0
	inx
	bne :+
	inc $f1
:	ldy $f1
	jmp file::load
.endproc

;--------------------------------------
;load loads the room data for the room name in (YX)
; format of room file:
; - picdata
; - exits (1 byte ID of rooms):
;   North
;   South
;   West
;   East
;   Up
;   Down
; - things table
; - room-description
; things data
.export __room_load
.proc __room_load
	jmp load_lpstr
.endproc

;--------------------------------------
;update updates tables with the buffered room data
.export __room_update
.proc __room_update
	@room = zp::tmp0
	@src = zp::tmp0
	@dst = zp::tmp2
	@t = zp::tmp4
	@desc = mem::roombuff + (ROOM_WIDTH*ROOM_HEIGHT)

	; load the room image data
	ldx #<mem::roombuff
	ldy #>mem::roombuff
	stx @src
	sty @src+1
	ldx #<($1100 + ($c0*4) + 16)
	ldy #>($1100 + ($c0*4) + 16)
	stx @dst
	sty @dst+1

	ldx #ROOM_WIDTH
@l1:	ldy #$00
@l0:	lda (@src),y
	sta (@dst),y
	iny
	cpy #ROOM_HEIGHT
	bne @l0

	lda @src
	clc
	adc #ROOM_HEIGHT
	bcc :+
	inc @src+1
:	sta @src

	lda @dst
	clc
	adc #$c0
	bcc :+
	inc @dst+1
:	sta @dst
	dex
	bne @l1

	; get the exits (len-prefixed)
	ldx #$00
	ldy #$00
@exits: lda @src
	sta exits,x
	lda @src+1
	sta exits+1,x
	lda (@src),y
	bne :+
	lda #$00
	sta exits,x
	sta exits+1,x
:	sec
	adc @src
	sta @src
	bcc :+
	inc @src+1
:	inx
	inx
	cpx #NUM_EXITS*2
	bne @exits

@name:	lda @src
	sta name
	lda @src+1
	sta name+1
	; get the room name
:	lda (@src),y
	incw @src
	cmp #$00
	bne :-

@description:
	lda @src
	sta description
	lda @src+1
	sta description+1
	; get the room description
:	lda (@src),y
	incw @src
	cmp #$00
	bne :-

	; get the things in the room
	; TODO
@things:

@done:
	jsr gui::clrtxt
	ldx app::cursor
	ldy app::cursor+1
	jsr sprite::on

	; write the room name
	ldx name
	ldy name+1
	jsr gui::name

	; write the room's description
	ldx description
	ldy description+1
	lda #20
	sta text::speed
	jsr gui::txt
	lda #0
	sta text::speed
	rts
.endproc

;--------------------------------------
; use runs the handler for the thing given in .A
.export use
.proc use
	asl
	tay
	lda usetable,y
	sta @handle
	lda usetable+1,y
	sta @handle+1
@handle=*+1
	jmp $ffff
.endproc

;--------------------------------------
; lookat prints the description for the thing given in .A
.proc lookat
	asl
	tay
	lda desctable,y
	tax
	lda desctable+1,y
	tay
	jsr gui::txt
	rts
.endproc

;--------------------------------------
; look prints the description of the selected thing.
.export __room_look
__room_look:
	lda #$01
	.byte $2c
;--------------------------------------
; handle runs the handler for the thing at the coordinates given in (.X,.Y) or,
; if there is nothing at that position, does nothing.
.export __room_use
.proc __room_use
@xpos=zp::tmpa
@ypos=zp::tmpb
@xstop=zp::tmpc
@ystop=zp::tmpd
@i=zp::tmpe
@use_or_look=zp::tmpf
@thing=zp::tmp10
	lda #$00
	sta @use_or_look
	lda #$00
	sta @i
@l0:	lda @i
	cmp numthings
	bcc :+
	rts

	; get the thing's positon
:	asl
	tay
	lda spritetable+1,x
	tay
	lda spritetable,x
	tax
	jsr sprite::pos
	stx @xpos
	sty @ypos

	; get the thing's dimensions and compute bounds of its rect
	lda @i
	asl
	tay
	lda spritetable+1,y
	tay
	lda spritetable,x
	tax
	jsr sprite::dim
	clc
	adc @ypos
	sta @ystop

	txa
	asl
	asl
	asl
	adc @xpos
	sta @xstop

	jsr app::curx
	cmp @xpos
	bcc @next
	cmp @xstop
	bcs @next

	jsr app::cury
	cmp @ypos
	bcc @next
	cmp @ystop
	bcs @next
	lda @i
	ldx @use_or_look	; do we want to LOOK or USE the selected thing?
	bne @look

@use:   jmp use
@look:  jmp lookat

@next:  inc @i
	lda @i
	cmp numthings
	bcc @l0
	rts
.endproc

;--------------------------------------
.export __room_north
.proc __room_north
	ldx #$00
	.byte $2c
.endproc
;--------------------------------------
.export __room_south
.proc __room_south
	ldx #$02
	.byte $2c
.endproc
;--------------------------------------
.export __room_east
.proc __room_east
	ldx #$04
	.byte $2c
.endproc
;--------------------------------------
.export __room_west
.proc __room_west
	ldx #$06
	.byte $2c
.endproc
;--------------------------------------
.proc __room_up
	ldx #$08
	.byte $2c
.endproc
;--------------------------------------
.proc __room_down
	ldx #$0a
	lda exits+1,x
	beq @done
	pha
	lda exits,x
	pha
	jsr fx::fadeout
	pla
	tax
	pla
	tay
	jsr __room_load
	jsr fx::fadein
	jsr __room_update
@done:	rts
.endproc
