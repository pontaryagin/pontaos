qemu-img create -f raw disk.img 200M
mkfs.fat -n 'PONTA OS' -s 2 -f 2 -R  32 -F 32  disk.img 
mkdir -p mnt
sudo mount -o loop disk.img mnt
sudo mkdir -p mnt/EFI/BOOT
sudo cp Loader.efi mnt/EFI/BOOT/BOOTX64.EFI
sudo umount mnt
# run
qemu-system-x86_64 -drive if=pflash,file=$HOME/osbook/devenv/OVMF_CODE.fd \
    -drive if=pflash,file=$HOME/osbook/devenv/OVMF_VARS.fd \
    -hda disk.img

