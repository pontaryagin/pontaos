.PHONY: Loader.efi
.DEFAULT_GOAL := all

BASEDIR:=x86_64-elf
CPPFLAGS:=-I$(BASEDIR)/include/c++/v1 -I$(BASEDIR)/include -I$(BASEDIR)/include/freetype2 -nostdlibinc -D__ELF__ -D_LDBL_EQ_DBL -D_GNU_SOURCE -D_POSIX_TIMERS
LDFLAGS:=-L$(BASEDIR)/lib
CPPFLAGS_EXTRA := -fno-threadsafe-statics ## static 変数のthread-safeなコードを避ける

setup_edk2:
	cd edk2; . edksetup.sh; cd -
	cp target.txt edk2/Conf/target.txt
	if [ ! -e edk2/MikanLoaderPkg ]; then ln -s $HOME/mikanos/MikanLoaderPkg edk2/MikanLoaderPkg ; fi

main.o: main.cpp
	clang++ $(CPPFLAGS) $(CPPFLAGS_EXTRA) -O2 -Wall -g --target=x86_64-elf -ffreestanding -mno-red-zone \
		-fno-exceptions -fno-rtti -std=c++17 -c main.cpp

kernel.elf: main.o
	ld.lld-7 $(LDFLAGS) --entry KernelMain -z norelro --image-base 0x100000 -static -o kernel.elf main.o

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
