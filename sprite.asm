.include "bitmap.inc"
.include "math.inc"
.include "memory.inc"
.include "types.inc"
.include "zeropage.inc"

.CODE
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
next_cols  = mem::spare

;19 cycles 8 bytes
.macro shift_blit
        lsr             ;2
        ror next_col    ;5
        sec             ;2
        ror alpha       ;5
        ror next_alpha  ;5
.endmacro

;--------------------------------------
;read in the sprite data for the sprite in (<.X, .Y>)
.export __sprite_load
__sprite_load:
.proc read_in
        stx zp::tmp0
        sty zp::tmp0+1
;get the X and Y coordinates of the sprite
        ldy #$00
        lda (zp::tmp0),y
        tax
        and #$07
        sta xpos
        txa
	and #$f8
        lsr
        lsr
        tax
        iny
        lda (zp::tmp0),y
        sta ypos

	;get the bitmap destination address of this sprite
        lda bm::columns,x
        clc
        adc ypos
        sta dst
        lda bm::columns+1,x
        adc #$00
        sta dst+1

	;get the address of the color data
	iny
	iny
	lda (zp::tmp0),y
        sta cdata
	iny
        lda (zp::tmp0),y
        sta cdata+1

	;get the sprite's width and height
	ldy #$00
	lda (cdata),y
	sta w
        iny
	lda (cdata),y
        sta h

	lda cdata
	clc
	adc #02
	sta cdata
	bcc :+
	inc cdata+1

:	; get size of color/alpha/backup buffers
        ldx w
        ldy h
        jsr m::mul8
        pha

	;get the address of the alpha mask
        clc
        adc cdata
        sta amask
        lda cdata+1
        adc #$00
        sta amask+1

	; get the address of backup buffer
        pla
        adc amask
        sta bakup
        lda amask+1
        adc #$00
        sta bakup+1
        rts
.endproc

;--------------------------------------
.export __sprite_on
.proc __sprite_on
        jsr __sprite_load ;get the sprite data

.export __sprite_draw
__sprite_draw:
        ldx h
	stx @smc0
        stx @smc2               ;set address of the next column alpha buffer
        stx @smc3
        stx @smc4
        lda #$00

	dex
;clear the color buffer ($00)
@l0:    sta next_cols,x
        dex
        bpl @l0
;clear the alpha buffer ($FF)
        lda #$ff
        ldx h
@smc0=*+1
@l1:    sta next_cols+0,x       ;SMC
        dex
        bpl @l1

        lda #$08
        sec
        sbc xpos

	;get amount to shift*8
	asl
        asl
        asl
        sta @smc1

	;do w columns of blitting
        ldx w
        ldy #$ff

;shift and blit the sprite
@shloop0:
        ldy h                   ;get # of lines to draw in this column
        dey
@shloop1:
        lda #$ff
        sta next_alpha          ;clear next alpha to $ff
        lda #$00
        sta next_col            ;clear next cdata to $00
        lda (amask),y
        sta alpha
        lda (dst),y             ;back up the area behind the sprite
        sta (bakup),y
        lda (cdata),y
@smc1=*+1
        bne *			;if data, jump to the appropriate shift amount
        shift_blit
        shift_blit
        shift_blit
        shift_blit
        shift_blit
        shift_blit
        shift_blit
        shift_blit
        ora (dst),y             ;OR with the current contents at the destination
        and alpha               ;clear the opaque 0's in the sprite data
        ora next_cols,y         ;OR with the last column's data
@smc2=*+1
        and next_cols+0,y       ;and with the last column's alpha
        sta (dst),y             ;finally, draw
        lda next_col
        sta next_cols,y
        lda next_alpha
@smc3=*+1
        sta next_cols,y
	dey                     ;next row
        bpl @shloop1            ;draw one column
        dex                     ;decrement column counter
        bne @cont               ;draw more columns
;draw the last column
        add16_8 dst, #$c0
        add16_8 bakup, h
        ldy h
        dey
@last_col:
        lda (dst),y
        sta (bakup),y
        ora next_cols,y
@smc4=*+1
        and next_cols+0,y
        sta (dst),y
        dey
        bpl @last_col
        rts                     ;done
;update the color, alpha mask, back up, and destination pointers
@cont:
	clc
        adc16_8 cdata, h
        add16_8 amask, h
        add16_8 bakup, h
        add16_8 dst, #$c0
        jmp @shloop0            ;draw the next column
.endproc

;--------------------------------------
.export __sprite_off
.proc __sprite_off
        jsr read_in             ;get the sprite data
;do w columns of restore
        ldx w
;shift and blit the sprite
@l0:
        ldy h                   ;get # of lines to restore in this column
        dey
@l1:
        lda (bakup),y
        sta (dst),y             ;OR with the current contents at the destination
        dey
        bpl @l1                 ;draw one column
        dex                     ;decrement column counter
        bpl @cont
        rts                     ;done
;update the color, alpha mask, and destination pointers
@cont:
        add16_8 bakup, h
        add16_8 dst, #$c0
@next_col:
        jmp @l0

;do unshifted blit
@noshloop:
        lda cdata,x
        and amask,x
        ora (cdata),y
        sta (cdata),y
        inx
        cpx w
        bcc @noshloop
@done:  rts
.endproc

;--------------------------------------
.export __sprite_set
.proc __sprite_set
	sty ypos
	txa
	and #$07
	sta xpos
	and #$f8
        lsr
        lsr
	tax

	;get the bitmap destination address of this sprite
        lda bm::columns,x
        clc
        adc ypos
        sta dst
        lda bm::columns+1,x
        adc #$00
        sta dst+1
	rts
.endproc

;--------------------------------------
; returns the sprite's width in .X and its height in .A
.export __sprite_dim
.proc __sprite_dim
@spr=zp::tmp0
	stx @spr
	sty @spr+1

	ldy #Sprite::data
	lda (@spr),y
	tax
	iny
	lda (@spr),y
	stx @spr
	sta @spr+1
	ldy #SpriteDat::W
	lda (@spr),y
	tax
	iny
	lda (@spr),y
	rts
.endproc

;--------------------------------------
; pos returns the position of the sprite in YX as the coordinates in (.X, .Y)
.export __sprite_pos
.proc __sprite_pos
@spr=zp::tmp0
	stx @spr
	sty @spr+1

	ldy #0
	lda (@spr),y
	tax
	iny
	lda (@spr),y
	tay
	rts
.endproc

;--------------------------------------
; returns sprite size in (<.X, >.A)
.export __sprite_size
.proc __sprite_size
@spr=zp::tmpa
@msb=zp::tmpc
@height=zp::tmpd
	stx @spr
	sty @spr+1
	ldy #SpriteDat::W
	lda (@spr),y
	tax
	ldy #SpriteDat::H
	lda (@spr),y
	sta @height
	tay
        jsr m::mul8
	ldy #$00
	sty @msb
	sta @spr
	asl		; *2 for alpha data
	rol @msb
	adc @spr	; *3 for backup buffer
	bcc :+
	inc @msb
:	clc
	adc @height	; backup buffer has 1 extra column
	bcc :+
	inc @msb
:	adc #2		; w/h
	tax
	lda @msb
	adc #$00
	rts
.endproc

;--------------------------------------
; xpos returns the x-position of the sprite in (YX)
.export __sprite_xpos
.proc __sprite_xpos
@spr=zp::tmp0
	stx @spr
	sty @spr+1
	ldy #$00
	lda (@spr),y
	rts
.endproc

;--------------------------------------
; ypos returns the y-position of the sprite in (YX)
.export __sprite_ypos
.proc __sprite_ypos
@spr=zp::tmp0
	stx @spr
	sty @spr+1
	ldy #$01
	lda (@spr),y
	rts
.endproc

;--------------------------------------
.export __sprite_testsprite
__sprite_testsprite:
.byte 1                 ;x coordinate
.byte 1                 ;y coordinate
.byte 1                 ;width is in # of characters (8 pixels)
.byte 7                 ;height is in # pixels - 1
.byte 0                 ;flags, unused
;color data
.byte %00001111
.byte %00011110
.byte %00111100
.byte %01111000
.byte %11110000
.byte %11100000
.byte %11000000
.byte %10000000
;alpha mask
.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
.endscope

