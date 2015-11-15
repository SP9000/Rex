.include "math.inc"
.include "zeropage.inc"
.include "bitmap.inc"
.include "memory.inc"

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
;19 cycles
.macro shift_blit
        lsr             ;2
        ror next_col    ;5
        sec             ;2 
        ror alpha       ;5
        ror next_alpha  ;5
.endmacro
;7 cycles
.macro shift_blit_f
        lsr             ;2
        ror next_col    ;5
.endmacro


;--------------------------------------
;turn on a very simple sprite (8x8)
.proc __sprite_8xn_on
@next   = zp::tmp0
@sprite = zp::tmp1
        stx @sprite
        sty @sprite+1
        ldy #$00
        lda (@sprite),y
.repeat 8, i
        .repeat i
                lsr
                ror @next
        .endrepeat

        sta bm::columns,y
.endrepeat 
.endproc

;--------------------------------------
;read in the sprite data for the sprite in (<.X, .Y>)
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
        iny
        and #$f8
        lsr
        lsr
        tax
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
;get the sprite's width and height
        iny
        lda (zp::tmp0),y
        sta w
        iny
        lda (zp::tmp0),y
        sta h
        iny
        iny
;get the address of the color data
        tya
        clc
        adc zp::tmp0
        sta cdata
        lda zp::tmp1
        adc #$00
        sta cdata+1
;get the address of the alpha mask
        ldx w
        ldy h
        jsr m::mul8
        pha
        clc
        adc cdata
        sta amask
        lda cdata+1
        adc #$00
        sta amask+1
        pla
        adc amask
        sta bakup
        lda amask+1
        adc #$00
        sta bakup+1
        rts
.endproc
;--------------------------------------
.export __sprite_on_f
.proc __sprite_on_f
        jsr read_in             ;get the sprite data
;clear the color buffer ($00)
        lda #$00
        ldx h
@l0:    sta next_cols,x
        dex
        bpl @l0

        lda #$08
        sec
        sbc xpos
        ;beq @noshloop           ;no shift, skip ahead
;get amount to shift*3
        sta zp::tmp0
        asl
        adc zp::tmp0
        sta @smc0
;do w columns of blitting
        ldx w
        ldy #$ff
;shift and blit the sprite
@shloop0:
        ldy h                   ;get # of lines to draw in this column
        dey
@shloop1:
        lda #$00
        sta next_col            ;clear next cdata to $00
        lda (cdata),y
        beq @next0              ;no data, skip to next line
@smc0=*+1
        bne @next0              ;if data, jump to the appropriate shift amount
        shift_blit_f
        shift_blit_f
        shift_blit_f
        shift_blit_f
        shift_blit_f
        shift_blit_f
        shift_blit_f
        shift_blit_f
        ora (dst),y             ;OR with the current contents at the destination
        ora next_cols,y         ;OR with the last column's data
        sta (dst),y
        lda next_col
        sta next_cols,y         
@next0: dey                     ;next row
        bpl @shloop1            ;draw one column
        dex                     ;decrement column counter
        bne @cont               ;draw more columns
;draw the last column
        add16_8 dst, #$c0
        ldy h
        dey
@last_col:
        lda next_cols,y
        sta (dst),y
        dey
        bpl @last_col
        rts                     ;done
;update the color, alpha mask, and destination pointers
@cont:
        adc16_8 cdata, h
        add16_8 dst, #$c0
@next_col:
        beq @done
        jmp @shloop0            ;draw the next column

;do unshifted blit
@noshloop:
        inc $900f
        jmp *
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
.export __sprite_on
.proc __sprite_on
        jsr read_in             ;get the sprite data
;clear the next column buffer and the next alpha buffer
        ldx h
        stx @smc1               ;set address of the next column alpha buffer
        stx @smc2    
        stx @smc3
        stx @l1+1               ;once again
        lda #$00
;clear the color buffer ($00)
@l0:    sta next_cols,x
        dex
        bpl @l0
;clear the alpha buffer ($FF)
        lda #$ff
        ldx h
@l1:    sta next_cols+0,x       ;SMC
        dex
        bpl @l1

        lda #$08
        sec
        sbc xpos
        ;beq @noshloop           ;no shift, skip ahead
;get amount to shift*8
        asl
        asl
        asl
        sta @smc0
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
        beq @next0              ;no data, skip to next line
@smc0=*+1
        bne @next0              ;if data, jump to the appropriate shift amount
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
@smc1=*+1
        and next_cols+0,y       ;and with the last column's alpha
        sta (dst),y             ;finally, draw 
        lda next_col
        sta next_cols,y         
        lda next_alpha
@smc2=*+1
        sta next_cols,y
@next0: dey                     ;next row
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
        lda (dst),y
        ora next_cols,y
@smc3=*+1
        and next_cols+0,y
        sta (dst),y
        dey
        bpl @last_col
        rts                     ;done
;update the color, alpha mask, back up, and destination pointers
@cont:
        adc16_8 cdata, h
        add16_8 amask, h
        add16_8 bakup, h
        add16_8 dst, #$c0
@next_col:
        beq @done
        jmp @shloop0            ;draw the next column

;do unshifted blit
@noshloop:
        inc $900f
        jmp *
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
        inc $900f
        jmp *
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
.export __sprite_off_f
.proc __sprite_off_f
        jsr read_in
        ldx w
@l0:    ldy h
        lda #$00
@l1:    sta (dst),y
        dey
        bpl @l1
        add16_8 dst, #$c0
        dex
        bpl @l0
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

