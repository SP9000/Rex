;--------------------------------------
; this file contains the most useful routines and variables for scripts


;--------------------------------------
; data
.import xpos ; the x-position of the cursor
.import ypos ; the y-position of the cursor
.import relx ; in a sprite handler, the relative x-position of the cursor (from top-left)
.import rely ; in a sprite handler, the relative y-position of the cursor (from top-left)

.import item ; the item that is currently selected

;--------------------------------------
; routines
.import die  ; game over
.import hit  ; hit effect
.import remove ; remove id

; UI routines
.import alert ; display a message and wait for FIRE
