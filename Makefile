.PHONY: Loader.efi
.DEFAULT_GOAL := all

setup_edk2:
	cd edk2; . edksetup.sh; cd -
	cp target.txt edk2/Conf/target.txt
	if [ ! -e edk2/MikanLoaderPkg ]; then ln -s $HOME/mikanos/MikanLoaderPkg edk2/MikanLoaderPkg ; fi

main.o: main.cpp
	clang++ -O0 -Wall -g --target=x86_64-elf -ffreestanding -mno-red-zone \
		-fno-exceptions -fno-rtti -std=c++17 -c main.cpp

kernel.elf: main.o
	ld.lld-7 --entry KernelMain -z norelro --image-base 0x100000 -static -o kernel.elf main.o

Loader.efi:
	set -ex && \
	cd edk2 && \
	source ./edksetup.sh && \
	build && \
	cp Build/PontaLoaderX64/DEBUG_CLANG38/X64/Loader.efi .. && \
	cd -

all: Loader.efi kernel.elf
	./run_efi.sh Loader.efi kernel.elf 1

clean:
	rm -rf edk2/Build
	rm *.o *.elf *.efi
