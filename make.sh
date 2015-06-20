ca65 boot.a65 -o boot.o
ca65 bitmap.a65 -o bitmap.o 
ca65 joystick.a65 -o joystick.o
ca65 math.a65 -o math.o
ca65 memory.a65 -o memory.o
ca65 sprite.a65 -o sprite.o
ca65 app_sprites.a65 -o app.o
ca65 irq.a65 -o irq.o
ca65 text.a65 -o text.o

ld65 -o rex.prg -C link.config boot.o memory.o bitmap.o math.o sprite.o joystick.o app.o irq.o text.o  -Ln labels.txt 


