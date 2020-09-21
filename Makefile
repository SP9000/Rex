SRC=$(wildcard *.asm)
FILES = $(filter-out rex.prg, $(wildcard *.prg))

disk: rex.prg
	c1541 -format "rex,rex" d64 rex.d64 -write rex.prg $(addprefix -write , $(FILES)) 

rex.prg: $(SRC)
	cl65 -t vic20 -o $@ -C link.config $^ -Ln labels.txt

export:
	python3 import_png.py overlay.png overlay.prg 0x1100
	python3 rooms.py

setup:
	pip3 install pillow

test:
	xvic -drive8type 1541 +truedrive -virtualdev -memory all -ntsc -8 rex.d64 rex.d64

test-td:
	xvic -drive8type 1541 -truedrive -virtualdev -memory all -ntsc -8 rex.d64 rex.d64

draw:
	xvic +truedrive -virtualdev +warp -memory all -ntsc minipaint.d64

clean:
	rm rex.prg
	rm *.o
	rm rex.d64
