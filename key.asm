.include "handlers.inc"
.include "gui.inc"
.include "zeropage.inc"

REPEAT_TMR=60
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
	beq @done
	cmp #$51
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
	bne @done
	jmp gui::drawinv

@done:	rts
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
