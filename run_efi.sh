#!/bin/bash

set -xe

EFI_FILE=${1:-Loader.efi}
KERNEL_FILE=${2}
DEBUG=${3}

rm -rf mnt disk.img
qemu-img create -f raw disk.img 200M
mkfs.fat -n 'PONTA OS' -s 2 -f 2 -R  32 -F 32  disk.img 
mkdir -p mnt
sudo mount -o loop disk.img mnt
sudo mkdir -p mnt/EFI/BOOT
sudo cp $EFI_FILE mnt/EFI/BOOT/BOOTX64.EFI
sudo cp $KERNEL_FILE mnt/kernel.elf
sudo umount mnt
if [ $DEBUG == 1 ]; then
    DEBUG_OPTION="-monitor stdio"
fi
# run
qemu-system-x86_64 -drive if=pflash,file=$HOME/osbook/devenv/OVMF_CODE.fd \
    -drive if=pflash,file=$HOME/osbook/devenv/OVMF_VARS.fd \
    -hda disk.img $DEBUG_OPTION

