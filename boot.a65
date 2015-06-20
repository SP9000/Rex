.include "bitmap.inc"
.include "text.inc"
.include "sprite.inc"
.include "app_sprites.inc"
.include "joystick.inc"
.include "irq.inc"

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

        lda #$00
        sta text::colstart
        lda #testlen
        sta text::len
        lda #5
        ldx #<test
        ldy #>test
        jsr text::puts

        ldx #<app::cursor
        ldy #>app::cursor
        jsr sprite::on
main:
        lda #$05
        cmp $9004
        bne *-3

        ldx #<app::cursor
        ldy #>app::cursor
        jsr sprite::off
        jsr joy::handle
        lda app::cursor+4

        ldx #<app::cursor
        ldy #>app::cursor
        jsr sprite::on
        jmp main

irq_handler:
        jmp $eabf

test: .byte "hello, friends"
testlen = *-test
