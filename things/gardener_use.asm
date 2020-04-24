.include "engine.inc"
	lda item
	cmp #$03	; TODO
	beq :+
	jmp die
:	rts

