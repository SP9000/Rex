INV_SIZE = 64

.export __item_list
__item_list:
	.res 2 * INV_SIZE

.export __item_len
__item_len:
	.byt 0

;--------------------------------------
;additem
.export __item_additem
.proc __item_additem
.endproc

;--------------------------------------
;take
.export __item_take
.proc __item_take
.endproc

;--------------------------------------
;use
.export __item_use
.proc __item_use
.endproc

;--------------------------------------
;discard
.export __item_discard
.proc __item_discard
.endproc
