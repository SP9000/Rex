.struct Thing
	id     .word ; unique identifier for the thing.
	sprite .word ; sprite identifier
	name   .word ; address of length-prefixed name of the thing.
	desc   .word ; address of length-prefixed description of the thing.
	data   .word ; address of thing specific data
	use    .word ; address of use callback.
		     ; the use callback contains the thing being used in
		     ; (zp::tmp0) and the ID of the thing that the thing is
		     ; being used on in .X.
.endstruct

.struct Sprite 
        xpos    .byte   ;the x coordinate
        ypos    .byte   ;the y coordinate
	width   .byte   ;sprite's width
	height  .byte   ;height of the sprite
        flags   .byte   ;user flags - unused
	data	.byte	;variable length
.endstruct

.struct Room
	img       .res 96/8*112
	numthings .byte
.endstruct

.struct SpriteDat
	W       .byte   ; width of the sprite data
	H	.byte   ; height of the sprite data
.endstruct
