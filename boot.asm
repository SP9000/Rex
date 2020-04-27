.include "app.inc"
.include "app_sprites.inc"
.include "bitmap.inc"
.include "driver.inc"
.include "file.inc"
.include "irq.inc"
.include "joystick.inc"
.include "key.inc"
.include "room.inc"
.include "sfx.inc"
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
	jsr driver::init
        jmp enter

;------------------------------------------------------------------------------
.CODE
enter:
        ldx #<irq_handler
        ldy #>irq_handler
        lda #$20
        jsr irq::raster
        jsr bm::init
        jsr bm::clr

	ldy #>overlayfile
	ldx #<overlayfile
	lda #overlaylen
	jsr file::load

	ldy #>room1
	ldx #<room1
	stx file::name
	sty file::name+1
	jsr room::load
	jsr room::update

	jsr test
main:
        lda #$70
        cmp $9004
        bne *-3

	jsr key::handle
        jsr joy::handle
        jmp main

irq_handler:
	jsr key::update
	jsr sfx::update
	lda sfx::playing
	bne :+
	jsr driver::play
:	jmp $eabf

overlayfile:
	.byt "overlay.prg"
overlayfileend:
overlaylen = overlayfileend - overlayfile

room1:
	.byt room1end - room1 - 1
	.byt "gazebo.prg"
room1end:
room2:
	.byt room2end - room2 - 1
	.byt "garden.prg"
room2end:
