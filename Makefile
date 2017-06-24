SRC=$(wildcard *.asm)
rex.prg: $(SRC)
	cl65 -o $@ -C link.config $^ -Ln labels.txt
	c1541 -format "rex,rex" d81 rex.d81 -write rex.prg rex.prg -write overlay.prg overlay.prg -write room.prg room.prg
	rm *.o

export:
	python export_room.py tunnel.prg room.prg

test:
	xvic -memory all -ntsc rex.d81

draw:
	xvic -memory all -ntsc minipaint.d64

clean:
	rm rex.prg
	rm *.o
