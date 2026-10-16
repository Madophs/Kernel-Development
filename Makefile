FILES = ./build/kernel.asm.o

all: ./bin/boot.bin ./bin/kernel.bin
	dd bs=512 if=./bin/boot.bin of=./bin/os.bin
	dd if=./bin/kernel.bin >> ./bin/os.bin
	# IO block = 512 bytes * 8
	truncate --size=2 --io-blocks ./bin/os.bin

./bin/boot.bin: ./src/boot/boot.asm
	nasm -f bin ./src/boot/boot.asm -o ./bin/boot.bin

./bin/kernel.bin: $(FILES)
	i686-elf-ld -g -relocatable $(FILES) -o ./build/kernelfull.o
	i686-elf-gcc -T ./src/linker.ld -o ./bin/kernel.bin -ffreestanding -O0 -nostdlib ./build/kernelfull.o

./src/kernel.asm.o: ./src/kernel.asm
	nasm -f elf ./src/kernel.asm -o ./build/kernel.asm.o

clean:
	rm -rf ./bin/*
	rm -rf ./build/*
