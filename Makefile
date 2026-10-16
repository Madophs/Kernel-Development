FILES = ./build/kernel.asm.o

all: ./bin/boot.bin ./bin/kernel.bin
	dd bs=512 if=./bin/boot.bin of=./bin/os.bin
	dd if=./bin/kernel.bin >> ./bin/os.bin
	truncate --size=51K ./bin/os.bin

./bin/boot.bin: ./src/boot/boot.asm
	nasm -g -f bin ./src/boot/boot.asm -o ./bin/boot.bin

./bin/kernel.bin: $(FILES)
	i686-elf-ld -g -relocatable $(FILES) -o ./build/kernelfull.o
	i686-elf-gcc -T ./src/linker.ld -o ./bin/kernel.bin -ffreestanding -O0 -nostdlib ./build/kernelfull.o

./build/kernel.asm.o: ./src/kernel.asm
	nasm -g -f elf ./src/kernel.asm -o ./build/kernel.asm.o

clean:
	rm -rf ./bin/*
	rm -rf ./build/*
