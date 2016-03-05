SRC=$(wildcard *.asm)
rex: $(SRC)
	cl65 -o $@ -C link.config $^ -Ln labels.txt
