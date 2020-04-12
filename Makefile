SRC=$(wildcard *.asm)
FILES = $(filter-out rex.prg, $(wildcard *.prg))

disk: rex.prg
	c1541 -format "rex,rex" d81 rex.d81 -write rex.prg $(addprefix -write , $(FILES))

rex.prg: $(SRC)
	cl65 -o $@ -C link.config $^ -Ln labels.txt


export:
	python3 import_png.py overlay.png overlay.prg 0x1100
	python3 rooms.py

test:
	xvic +truedrive -drive8type 1581 -virtualdev -memory all -ntsc -8 rex.d81 rex.d81 

draw:
	xvic +truedrive -virtualdev +warp -memory all -ntsc minipaint.d64

clean:
	rm rex.prg
	rm *.o
	rm rex.d81
