.include "macros.inc"
.include "memory.inc"
.include "zeropage.inc"

.CODE

DEVICE = 8

.export __file_name
__file_name: .word 0

.export __file_size
__file_size: .word 0

.export __file_lf
__file_lf: .byte 2

.export __file_loadaddr
__file_loadaddr: .word mem::spare

.export __file_eof
__file_eof: .byte 0

SA=2

;--------------------------------------
; open sets up the filename given in (YX) (of length given in .A)
; Call loadb to load each byte
.export __file_open
.proc __file_open
	jsr $ffc0 	; call OPEN
	bcs @error
	lda #$00
	sta __file_eof
	bcs @error 	; if carry set, the file could not be opened
	ldx #$02
	jmp $ffc6     ; CHKIN (lf now used as input)
@error: inc $900f
	jmp *-3
.endproc

;--------------------------------------
; loadto loads the filename in (YX) (of the length given in .A) to the address
; in zp::tmp0.
.export __file_loadto
.proc __file_loadto
@dst=zp::tmp0
	jsr fsetup
	jsr __file_open
	ldx __file_loadaddr
	ldy __file_loadaddr+1
	stx @dst
	sty @dst+1
	lda #$00
	sta __file_eof
@l0:    jsr __file_loadb
	ldx __file_eof
	bne @done
	ldy #$00
	sta (@dst),y
	incw @dst
	jmp @l0
@err:	sei
	inc $900f
@done:  rts
.endproc

;--------------------------------------
; loadb loads the next byte from the last "loaded" file.
; returns 0 in .A if EOF
.export __file_loadb
.proc __file_loadb
 	jsr $ffb7     ; call READST (read status byte)
	cmp #$00
	bne @eof      ; either EOF or read error
	jmp $ffcf     ; call CHRIN (get a byte from file)

@eof:   and #$40      ; end of file?
	beq @error
@close:
	inc __file_eof
	lda #2
	jsr $ffc3     ; call CLOSE
	jsr $ffcc     ; call CLRCHN
	lda #$00
	rts
@error:
	sei
	inc $900f
	jmp *-3
.endproc

;--------------------------------------
.proc fsetup
	ldx __file_name
	ldy __file_name+1
	stx @0+1
	sty @0+2
@0:	lda $ffff
	inx
	bne :+
	iny
:	jsr $ffbd	; SETNAM

	ldx #DEVICE
	ldy #SA
	lda #2		; file # 2
	jmp $ffba	; SETLFS
.endproc

;--------------------------------------
.export __file_close
.proc __file_close
	lda #$00
	jsr $ffc3
	lda #$01
	jsr $ffc3
	lda #$02
	jsr $ffc3
	jmp $ffcc
.endproc

;--------------------------------------
; load loads the file in (name).
.export __file_load
.proc __file_load
	jsr $ffbd     ; call SETNAM
	lda #$01
	ldx $ba       ; last used device number
	bne :+
	ldx #$08      ; default to device 8
:	ldy #$01      ; not $01 means: load to address stored in file
	jsr $ffba     ; call SETLFS
	lda #$00      ; $00 means: load to memory (not verify)
	jsr $ffd5     ; call LOAD
	bcs @error    ; if carry set, a load error has happened
	rts
@error:
	inc $900f
	jmp @error
.endproc

;--------------------------------------
; save (size) bytes of memory from (<.X/>.Y) to a file whose name is in (name).
.export __file_save
.proc __file_save
	txa
	pha
	tya
	pha

	jsr fsetup

	pla
	tay
	pla
	tax
	ldx #<__file_size
	ldy #>__file_size
	stx zp::tmp0
	sty zp::tmp0+1
	lda #zp::tmp0
	jsr $ffd5	; SAVE

	rts
.endproc

