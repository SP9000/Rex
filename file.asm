.include "zeropage.inc"

.export __file_name
__file_name:
.word 0

.export __file_size
__file_size:
.word 0

.CODE

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

	ldx #$08
	ldy #$01
	jsr $ffba	; SETLFS
	rts
.endproc

;--------------------------------------
; load loads the file in (name).
.export __file_load
.proc __file_load
	jsr fsetup

	lda #$00
	jsr $ffd5	; LOAD
	rts
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

