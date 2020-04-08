
;inializes the screen to a MINIGRAFIK bitmap
.import __bm_init

;clears the bitmap
.import __bm_clr

;sets the given pixel at the given (x,y) coordinates
;X: the x-coordinate
;Y: the y-coordinate
.import __bm_setpixel

;clears the given pixel at the given (x,y) coordinates
;X: the x-coordinate
;Y: the y-coordinate
.import __bm_clrpixel

;toggles the pixel at the given (x,y) coordinates
;X: the x-coordinate
;Y: the y-coordinate
.import __bm_togglepixel

;contains the address of each column within the bitmap
.import __bm_columns

.import __bm_hline
.import __bm_restorerow
.import __bm_restorehline

.scope bm
        init        = __bm_init
        clr         = __bm_clr
        setpixel    = __bm_setpixel
        clrpixel    = __bm_clrpixel
        togglepixel = __bm_togglepixel
        columns     = __bm_columns
	hline       = __bm_hline
	restorerow  = __bm_restorerow
	restorehline = __bm_restorehline
.endscope

