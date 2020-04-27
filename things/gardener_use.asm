.include "engine.inc"
.include "items.inc"
	lda item
	cmp #$03	; TODO
	beq @kill
	jsr hit

	ldx #<msg
	ldy #>msg
	jsr alert
	jmp die

@kill:
	lda #ITEM_gardener
	ldx #<killmsg
	ldy #>killmsg
	jsr alert
	jmp remove

msg: .byte "the gardener lashes out as you approach and flings his lantern at you. before you can react, you are engulfed in an unbearably hot blaze.",0

killmsg: .byte "the lantern in the gardener's hand bursts into a blinding ball of plasma. you avert your eyes and return them to find the cloaked ancient utterly vaporized.",0
