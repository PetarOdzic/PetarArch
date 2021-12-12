# PetarArch
A repository where I can put in info and files of my Arch Linux installation(attempts).

#Base installation commands
Becaus I use the US_ISO layout and Arch Linux is defaulted to that layout, I won't need to configure these.

ping 8.8.8.8

timedatectl set-ntp true

fdisk -l
fdisk /dev/[DISK]

Here i will create 3 partitions: efi, swap and root(home too?)

mkfs.xfs /dev/[ROOT_PARTITION]
mkswap /dev/[SWAP_PARTITION]
mkfs.fat -F 32 /dev/[EFI_PARTITION]

mount /dev/[ROOT_PARTITION] /mnt
mount /dev/[EFI_PARTITION] /mnt/boot
swapon /dev/[SWAP_PARTITION]

I figure to configure the pacman mirrors after the base installation as the defaults work good for me.

pacstrap /mnt base linux linux-firmware

genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt

ln -sf /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
hwclock --systohc
locale-gen {and incomment nl_US.UTF-8}
nano /etc/locale.conf {and write LANG=en_UK.UTF-8}
nano /etc/vconsole.conf {and write KEYMAP=us-latin1}

nano /etc/hostname {and enter a hostname like petar-arch}
hostnamectl set-hostname [HOSTNAME]
nano /etc/hosts {and type:
127.0.0.1        localhost
::1              localhost
127.0.1.1        myhostname
}

mkinitcpio -P

passwd
useradd -m -g users -G wheel petar
passwd jay

pacman -Syyu
pacman -S grub efibootmgr dosfstools os-prober mtools networkmanager
mkdir /boot/efi
mount /dev/sda1 /boot/efi
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck (if it cant find the efi directory, i will add flag: --efi-directory=/boot/efi)
grub-mkconfig -o /boot/grub/grub.cfg
(something was said about microcode for AMD or intel systems, might look into that)

systemctl enable NetworkManager

reboot

#Post-base installation
sudo pacman -S xorg-server plasma-meta sddm amd-ucode sudo onlyoffice code base-devel htop neofetch

