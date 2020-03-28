.include "zeropage.inc"
.include "memory.inc"

.CODE

DEVICE = 8

.export __file_name
__file_name: .word 0

.export __file_size
__file_size: .word 0

.export __file_loadaddr
__file_loadaddr: .word mem::spare

;--------------------------------------
.proc fsetup
	ldx __file_name
	ldy __file_name+1
setup:
	stx @0+1
	sty @0+2
@0:	lda $ffff
	inx
	bne :+
	iny
:	jsr $ffbd	; SETNAM

	ldx #DEVICE
	ldy #$01
	jmp $ffba	; SETLFS
.endproc

;--------------------------------------
.proc close
	lda #$0f
	jmp $ffcc
.endproc

;--------------------------------------
; load loads the file in (name).
.export __file_load
.proc __file_load
	jsr fsetup

	lda #$00
	jsr $ffd5	; LOAD
	jmp close
.endproc

;--------------------------------------
; loadsec loads the sector whose # is given in (YX)
; the offset to load is given in .A
.export __file_loadsec
.proc __file_loadsec
@dst=zp::tmp0
	stx @sec
	sty @sec+1
	sta @track
	; open channel file
	lda #@namelen
	ldx #<@name
	ldy #>@name
	jsr $ffbd 	; SETNAM
	lda #$02
	ldx #DEVICE	; device 8
	ldy #$02	; secondary addr
	jsr $ffba 	; SETLFS
	jsr $ffc0 	; OPEN
	bcs @err

	; open command channel
	lda #@cmdlen
	ldx #<@cmd
	ldy #>@cmd
	jsr $ffbd
	lda #$0f	; file #15
	ldx #DEVICE
	ldy #$0f	; secondary addr
	jsr $ffba 	; SETLFS
	jsr $ffc0	; OPEN command channel
	bcs @err

	ldx #$02
	jsr $ffc6	; CHKIN- use file #2 as input

	ldx __file_loadaddr
	ldy __file_loadaddr+1
	stx @dst
	sty @dst+1

	ldy #$00
@l0:	jsr $ffcf	; CHRIN- get byte
	sta (zp::tmp0),y
	iny
	bne @l0

	lda #$0f
	jsr $ffc3	; CLOSE channel file
	lda #$02
	jsr $ffc3	; CLOSE command channel
	jmp $ffcc	; CLRCHN

@err:	rts

@name: .byte '#'
@namelen=*-@name

@cmd: .byte "u1 2 0 "
@cmdlen=*-@cmd

@sec: .byte 0,0," "
@track: .byte 0,0,0
@cmdsize=*-@cmd
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

