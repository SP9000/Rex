;.A = .X * .Y
.import __math_mul8

;------------------------------------------------------------------------------
;Adds an 8 bit number (b) to a 16 bit number (a)
.macro  add16_16 num1, num2
        clc
        lda num1
        .if (.match (.left (1, {num8}), #))
                ;immediate
                adc #<(.right (.tcount ({num2})-1, {num2}))
                sta num1
                adc #>(.right (.tcount ({num2})-1, {num2}))
                sta num1+1
        .else
                ;zero page/absolute
                adc num2
                sta num1
                lda num1+1
                adc num2+1
        .endif
        sta num1+1
.endmacro
;------------------------------------------------------------------------------
;Adds an 8 bit number (b) to a 16 bit number (a) WITH carry
.macro  adc16_16 num1, num2
        lda num1
        .if (.match (.left (1, {num8}), #))
                ;immediate
                adc #<(.right (.tcount ({num2})-1, {num2}))
                sta num1
                adc #>(.right (.tcount ({num2})-1, {num2}))
                sta num1+1
        .else
                ;zero page/absolute
                adc num2
                sta num1
                lda num1+1
                adc num2+1
        .endif
        sta num1+1
.endmacro
;------------------------------------------------------------------------------
;Adds an 8 bit number (b) to a 16 bit number (a)
.macro  add16_8 num16, num8
        clc
        lda num16
        adc num8
        bcc :+
        inc num16+1
:       sta num16
.endmacro
;------------------------------------------------------------------------------
;Adds an 8 bit number (b) to a 16 bit number (a) the carry is not cleared prior
;to this operation
.macro  adc16_8 num16, num8
        lda num16
        adc num8
        bcc :+
        inc num16+1
:       sta num16
.endmacro

.scope m
       mul8     = __math_mul8
.endscope
