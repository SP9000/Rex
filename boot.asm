.include "app.inc"
.include "app_sprites.inc"
.include "bitmap.inc"
.include "file.inc"
.include "irq.inc"
.include "joystick.inc"
.include "key.inc"
.include "room.inc"
.include "sprite.inc"
.include "text.inc"

.import test

;------------------------------------------------------------------------------
.segment "SETUP"
.word head
head: .word @Next
.word .version
.byte $9e
.asciiz "4621"
@Next: .word 0
;------------------------------------------------------------------------------
start:
        jsr joy::init
        ldx #<irq_handler
        ldy #>irq_handler
        lda #$20
        jsr irq::raster
        jmp enter

;------------------------------------------------------------------------------
.CODE
enter:
        jsr bm::init
        jsr bm::clr

	ldy #>overlayfile
	ldx #<overlayfile
	stx file::name
	sty file::name+1
	jsr file::load

	ldx #<room1
	ldy #>room1
	stx file::name
	sty file::name+1
	jsr room::load

	jsr test
	ldx app::cursor
	ldy app::cursor+1
	jsr sprite::on
main:
        lda #$05
        cmp $9004
        bne *-3

        ldx app::cursor
        ldy app::cursor+1
        jsr sprite::off

	jsr key::handle
        jsr joy::handle

        ldx app::cursor
        ldy app::cursor+1
        jsr sprite::on
        jmp main

irq_handler:
        jmp $eabf

overlayfile:
	.byt overlayfileend - overlayfile - 1
	.byt "overlay.prg"
overlayfileend:

room1:
	.byt room1end - room1 - 1
	.byt "room.prg"
room1end:
