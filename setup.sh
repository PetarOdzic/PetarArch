#!/usr/bin/env bash

####################
# Pre Installation #
####################

## Ensure accurate systemclock
timedatectl set-ntp true

## Creating partition table, partitions and partitioning them.
fdisk /dev/nvme1n1
# to create partition table GPT, and 3 partitions(1. boot, 2. swap, 3. root)
mkfs.btrfs /dev/nvme1n1p3
mkswap /dev/nvme1n1p2
mkfs.fat -F32 /dev/nvme1n1p1

## Mount partitions
mount /dev/nvme1n1p3 /mnt
mkdir /mnt/boot
mount /dev/nvme1n1p1 /mnt/boot
swapon /dev/nvme1n1p2

################
# Installation #
################

## Installing essentials.
pacman -Syy
pacstrap /mnt base linux linux-firmware

## Chrooting to the root partition.
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt

## Configuring locales
ln -sf /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
hwclock --systohc
locale-gen {and incomment en_US.UTF-8}
echo "en_US.UTF-8"
nano /etc/locale.conf
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

# Configuring hostname
touch /etc/hostname {and enter a hostname like petar-arch}
hostnamectl set-hostname myarch
touch /etc/hosts {and type: 127.0.0.1 localhost ::1 localhost 127.0.1.1 myarch }
echo -e "127.0.0.1\tlocalhost\n::1\t\tlocalhost\n127.0.1.1\tmyarch.localdomain\tmyarch"

## This
mkinitcpio -P

#adding users and passwords here

#####################
# Post installation #
#####################

## Installing networking tools, grub and configuring grub.
pacman -Syyu pacman -S grub efibootmgr dosfstools os-prober mtools networkmanager dhcpcd
mkdir /boot/efi
mount /dev/sda1 /boot/efi
grub-install --target=x86_64-efi --bootloader-id=ARCH_GRUB --efi-directory=/boot/efi --recheck
grub-mkconfig -o /boot/grub/grub.cfg

## Installing drivers, KDE plasma and other programs
pacman -S xf86-video-amdgpu xorg-server plasma-desktop sddm amd-ucode alacritty sudo git onlyoffice code base-devel htop neofetch nano
systemctl enable NetworkManager
systemctl enable sddm

## END OF FILE
