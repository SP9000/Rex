SRC=$(wildcard *.asm)
rex.prg: $(SRC)
	cl65 -o $@ -C link.config $^ -Ln labels.txt
test:
	xvic -memory all -ntsc rex.prg
clean:
	rm rex.prg
	rm *.o
