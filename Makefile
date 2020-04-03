SRC=$(wildcard *.asm)
rex.prg: $(SRC)
	cl65 -o $@ -C link.config $^ -Ln labels.txt
	c1541 -format "rex,rex" d81 rex.d81 -write rex.prg rex -write overlay.prg overlay.prg -write room.prg room.seq
	rm *.o

export:
	python export_room.py tunnel.prg room.prg

test:
	xvic +truedrive -drive8type 1581 +warp -memory all -ntsc -8 rex.d81 -autostart rex.prg

draw:
	xvic +truedrive -virtualdev +warp -memory all -ntsc minipaint.d64

clean:
	rm rex.prg
	rm *.o
	rm rex.d81
