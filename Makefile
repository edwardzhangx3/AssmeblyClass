all: mario
mario: mario.o asm_io.o io.o
	gcc -m32 -o $@ $+ $(HOME)/templateMake/driver.c

mario.o: mario.asm 
	nasm -f elf mario.asm -o mario.o

asm_io.o: $(HOME)/templateMake/asm_io.asm 
	nasm -f elf -d ELF_TYPE $(HOME)/templateMake/asm_io.asm -o asm_io.o

io.o: io.asm 
	nasm -f elf -d ELF_TYPE io.asm -o io.o

clean:
	rm *.o mario
