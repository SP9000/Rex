.include "app.inc"
.include "file.inc"
.include "gui.inc"
.include "macros.inc"
.include "math.inc"
.include "memory.inc"
.include "sprite.inc"
.include "types.inc"
.include "zeropage.inc"
.CODE

ROOM_WIDTH = 96/8
ROOM_HEIGHT = 112

MAX_EXITS = 5
MAX_DOORS = 8
MAX_THINGS = 8

;--------------------------------------
numrooms: .byt 0
numexits: .byt 0
numdoors: .byt 0

spritetable: .res MAX_THINGS*2
postable: .res MAX_THINGS*2
idstable: .res MAX_THINGS*2
nametable: .res MAX_THINGS*2
desctable: .res MAX_THINGS*2
usetable: .res MAX_THINGS*2
numthings: .byte 0

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
;load loads the room data for the room in the sector given in (YX)
; format of room file:
; picdata
; room-description
; exits
; doors
.export __room_load
.proc __room_load
@room = zp::tmp0
@src = zp::tmp0
@dst = zp::tmp2
@t = zp::tmp4
@desc = mem::spare + (ROOM_WIDTH*ROOM_HEIGHT)
	lda #<mem::spare
	sta file::loadaddr
	lda #>mem::spare
	sta file::loadaddr+1
	jsr file::loadsec 	; load into spare memory

	; load the room image data
	ldx #<mem::spare
	ldy #>mem::spare
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

	rts

	; get the room description
@l2:	iny
	lda (@src),y
	sta (@dst),y
	bne @l2
	tya
	clc
	adc @src
	sta @src+1
	bcc :+
	inc @src+1
:	tya
	adc @dst
	sta @dst+1
	bcc :+
	inc @dst+1

	; get the things in the room
:	iny
	lda (@src),y	; # of things
	sta numthings
	sta @t
	beq @done
	incw @src
	incw @dst

@l3:	jsr getthing
	dec @t
	bne @l3

@done:
	; write the room's description
	ldx #<@desc
	ldy #>@desc
	jsr gui::txt
	rts
.endproc

;--------------------------------------
.proc getthing
@src=zp::tmp0
@sprite=zp::tmp2
@t = zp::tmp4
	ldx @t

@getid:
	ldy #$00
	lda (@src),y
	sta idstable,x
	iny
	lda (@src),y
	sta idstable+1,x

@getsprite:
	; get sector number of sprite graphic
	iny
	lda (@src),y
	tax
	iny
	lda (@src),y
	tay

	; load the sprite graphic from its sector
	jsr file::loadsec

	; store the sprite address in the sprites table
	lda @t
	asl
	tay
	lda file::loadaddr
	sta spritetable,y
	sta @sprite
	lda file::loadaddr+1
	sta spritetable+1,y
	sta @sprite+1

	; update the address to load the next sprite into
	ldy #$00
	lda (@sprite),y
	tax
        iny
	lda (@sprite),y
	tay
        jsr m::mul8
	asl
	adc file::loadaddr
	sta file::loadaddr
	bcc @getname
	inc file::loadaddr

@getname:
	; add name pointer to name table
	ldy #Thing::name
	adc @src
	ldx @t
	sta nametable,x
	lda @src+1
	adc #$00
	sta nametable+1,x
	jsr @readstr

	; add description pointer to desc table
	adc @src
	ldx @t
	sta desctable,x
	lda @src+1
	adc #$00
	sta desctable+1,x
	jsr @readstr

	; store pointer for handler callback in use table
	; get the size of the callback (2 bytes)
	lda (@src),y
	clc
	adc @src
	tay
	php
	incw @src
	lda (@src),y
	adc @src+1
	pha
	incw @src

	lda @src
	sta usetable,x
	lda @src+1
	sta usetable+1,x

	; update @src pointer to point past end of callback
	tya
	sta @src
	pla
	plp
	adc @src+1
	sta @src+1
	rts

; find terminator for string
@readstr:
	tya
	adc @src
	sta @src
	lda @src+1
	adc #$00
	sta @src+1
	ldy #$00
@l0:	lda (@src),y
	php
	incw @src
	plp
	bne @l0
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
	lda postable,x
	sta @xpos
	lda postable+1,x
	sta @ypos

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
