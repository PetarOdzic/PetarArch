#!/usr/bin/env bash

####################
# Pre Installation #
####################

timedatectl set-ntp true

################
# Installation #
################

fdisk /dev/nvme1n1
# Create partition table GPT, and 3 partitions(1. boot, 2. swap, 3. root)
mkfs.btrfs /dev/nvme1n1p3
mkswap /dev/nvme1n1p2
mkfs.fat -F32 /dev/nvme1n1p1

mount /dev/nvme1n1p3 /mnt
mkdir /mnt/boot
mount /dev/nvme1n1p1 /mnt/boot
swapon /dev/nvme1n1p2

pacman -Syy
pacstrap /mnt base linux linux-firmware

genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt

ln -sf /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
hwclock --systohc
locale-gen {and incomment en_US.UTF-8}
nano /etc/locale.conf {and write LANG=en_US.UTF-8}

touch /etc/hostname {and enter a hostname like petar-arch}
hostnamectl set-hostname myarch
touch /etc/hosts {and type: 127.0.0.1 localhost ::1 localhost 127.0.1.1 myarch }

mkinitcpio -P

#adding users here

#####################
# Post installation #
#####################

pacman -Syyu pacman -S grub efibootmgr dosfstools os-prober mtools networkmanager
mkdir /boot/efi
mount /dev/sda1 /boot/efi
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --efi-directory=/boot/efi --recheck
grub-mkconfig -o /boot/grub/grub.cfg

pacman -S xf86-video-amdgpu xorg-server plasma-desktop sddm amd-ucode alacritty sudo onlyoffice code base-devel htop neofetch nano
systemctl enable NetworkManager
systemctl enable sddm
