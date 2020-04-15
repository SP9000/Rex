.segment "ROOMBUFFER"
.scope mem
.export __mem_roombuff
__mem_roombuff:
	.res 12*112 ; picdata
	.res 6*16   ; exits
	.res 384    ; description
	.res 666    ; things (sprites/handlers)
.export __mem_spare
__mem_spare:
        .res 512
.endscope

