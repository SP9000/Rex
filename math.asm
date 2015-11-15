.include "zeropage.inc"
.CODE
;--------------------------------------
.export __math_mul8
.proc __math_mul8
        stx zp::arg0
        sty zp::arg1
        lda #$00
        beq @enterLoop
@doAdd:
        clc
        adc zp::arg0
@loop:
        asl zp::arg0
@enterLoop: ;For an accumulating multiply (.A = .A + num1*num2), set up num1 and num2, then enter here
        lsr zp::arg1
        bcs @doAdd
        bne @loop
        rts
.endproc
