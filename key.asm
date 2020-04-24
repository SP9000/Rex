.include "constants.inc"
.include "gui.inc"
.include "handlers.inc"
.include "inventory.inc"
.include "zeropage.inc"

REPEAT_TMR=10
repeat: .byte REPEAT_TMR

.CODE
;--------------------------------------
.export __key_update
.proc __key_update
	lda repeat
	beq @done
	dec repeat
@done:	rts
.endproc

;--------------------------------------
.export __key_handle
.proc __key_handle
	jsr __key_get
	bne :+
	rts

:	cmp #$51
	bne @chkexits
	on_space
	rts

@chkexits:
	cmp #$72	; E
	bne :+
	jmp room::east

:	cmp #$22	; W
	bne :+
	jmp room::west

:	cmp #$62	; S
	bne :+
	jmp room::south

:	cmp #$45	; N
	bne :+
	jmp room::north

:	cmp #$25	; I
	bne :+
	jmp gui::drawinv

:	cmp #$85	; 0
	bne :+
	lda #$00
	jmp inv::select

:	cmp #$11	; 1
	bne :+
	lda #$01
	jmp inv::select

:	cmp #$81	; 2
	bne :+
	lda #$02
	jmp inv::select

:	cmp #$12	; 3
	bne :+
	lda #$03
	jmp inv::select

:	cmp #$82	; 4
	bne :+
	lda #$04
	jmp inv::select

:	cmp #$13	; 5
	bne :+
	lda #$05
	jmp inv::select

:	cmp #$83	; 6
	bne :+
	lda #$06
	jmp inv::select

:	cmp #$14	; 7
	bne :+
	lda #$07
	jmp inv::select

:	cmp #$84	; 8
	bne :+
	lda #$08
	jmp inv::select

:	cmp #$15	; 9
	bne :+
	lda #$09
	jmp inv::select

:	cmp #$36	; L
	bne :+
	lda #ACTION_LOOK
	jmp app::setaction

:	cmp #$75	; O
	bne :+
	lda #ACTION_USE
	jmp app::setaction

:	cmp #$73	; T
	bne :+
	lda #ACTION_TAKE
	jmp app::setaction

:	rts
.endproc

;--------------------------------------
; read one key from the keyboard. code (col bit # << 4) + row bit #) returned in .A
;     7   6   5   4   3   2   1   0
;    --------------------------------
;  7| F7  F5  F3  F1  CDN CRT RET DEL    CRT=Cursor-Right, CDN=Cursor-Down
;   |
;  6| HOM UA  =   RSH /   ;   *   BP     BP=British Pound, RSH=Should be Right-SHIFT,
;   |                                    UA=Up Arrow
;  5| -   @   :   .   ,   L   P   +
;   |
;  4| 0   O   K   M   N   J   I   9
;   |
;  3| 8   U   H   B   V   G   Y   7
;   |
;  2| 6   T   F   C   X   D   R   5
;   |
;  1| 4   E   S   Z   LSH A   W   3      LSH=Should be Left-SHIFT
;   |
;  0| 2   Q   CBM SPC STP CTL LA  1      LA=Left Arrow, CTL=Should be CTRL, STP=RUN/STOP
;   |                                    CBM=Commodore key
;
.export __key_get
.proc __key_get
@row=zp::tmp0
@col=zp::tmp1
	lda repeat
	beq @ok
	lda #$00	; repeat is still in countdown
	rts
@ok:
	sei
	lda #$00
	sta $9123	; port A output
	lda #$ff
	sta $9122	; port B input

	lda #$01
	sta @col

	ldy #$01
@l0:	lda @col
	eor #$ff
	sta $9120
	lda #$01
	sta @row

	ldx #$01
@l1:	lda $9121	; read port B
	and @row
	beq @found
	inx
	asl @row
	bne @l1
	iny
	asl @col
	bne @l0
@notfound:
	lda #$00
	cli
	rts
@found:
	stx @row
	tya
	asl
	asl
	asl
	asl
	adc @row
	ldx #REPEAT_TMR
	stx repeat
	cli
	rts
.endproc
