.CODE
.export __app_cursor_sprite
__app_cursor_sprite:
.byte 4
.byte 1
.byte 0
.word __gfx_cursor

.export __app_rock
__app_rock:
.byte 60
.byte 70
.byte 0
.word rock_dat

rock_dat:
.byte 1
.byte 12
;color
.byte %10000000
.byte %11000000
.byte %10100000
.byte %10010000
.byte %10001000
.byte %10100100
.byte %10110100
.byte %10000100
.byte %11001100
.byte %00110010
.byte %00010110
.byte %00011100
;alpha
.byte %11111111
.byte %11111111
.byte %10111111
.byte %10011111
.byte %10001111
.byte %10100111
.byte %10110111
.byte %10000111
.byte %11001111
.byte %11110011
.byte %11110111
.byte %11111111
;back up
.res 12*2

.export __gfx_cursor
__gfx_cursor:
.byte 1
.byte 12

.byte %10000000
.byte %11000000
.byte %10100000
.byte %10010000
.byte %10001000
.byte %10100100
.byte %10110100
.byte %10000100
.byte %11001100
.byte %00110010
.byte %00010110
.byte %00011100
; alpha
.byte %11111111
.byte %11111111
.byte %10111111
.byte %10011111
.byte %10001111
.byte %10100111
.byte %10110111
.byte %10000111
.byte %11001111
.byte %11110011
.byte %11110111
.byte %11111111
;back up
.res 12*2

.export __gfx_eye
__gfx_eye:
.byte 2
.byte 8

.byte 3,28,96,131,131,96,28,3
.byte 192,56,6,193,193,6,56,192
.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
.res 8*3
