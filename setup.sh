#!/usr/bin/env bash

####################
# Pre Installation #
####################

## Ensure accurate systemclock
timedatectl set-ntp true

## Installing essentials for partitioning
pacman -Syy gptfdisk btrfs-progs

## Creating partition table, partitions and partitioning them.
sgdisk -Z /dev/nvme1n1 # zap all on disk
sgdisk -a 2048 -o /dev/nvme1n1
sgdisk -n 1::+300M --typecode=1:ef00 --change-name=1:'EFIBOOT' /dev/nvme1n1
sgdisk -n 2::+32G --typecode=2:8200 --change-name=2:'SWAP' /dev/nvme1n1
sgdisk -n 3::-0 --typecode=3:8304 --change-name=3:'ROOT' /dev/nvme1n1
mkfs.fat -F 32 /dev/nvme1n1p1
mkfs.btrfs /dev/nvme1n1p3
mkswap /dev/nvme1n1p2

## Mount partitions
mount /dev/nvme1n1p3 /mnt
mkdir /mnt/boot
mount /dev/nvme1n1p1 /mnt/boot
swapon /dev/nvme1n1p2

################
# Installation #
################

## Installing base system.
pacstrap /mnt base linux linux-firmware

## Chrooting to the root partition.
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt

## Configuring locales
ln -sf /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
hwclock --systohc
locale-gen {and incomment en_US.UTF-8}
sed -i "en_US.UTF-8" /etc/locale.gen
nano /etc/locale.conf
sed -i "LANG=en_US.UTF-8" /etc/locale.conf

# Configuring hostname
touch /etc/hostname {and enter a hostname like petar-arch}
sed -i "myarch" /etc/hostname
hostnamectl set-hostname myarch
touch /etc/hosts {and type: 127.0.0.1 localhost ::1 localhost 127.0.1.1 myarch }
sed -i "127.0.0.1\tlocalhost\n::1\t\tlocalhost\n127.0.1.1\tmyarch.localdomain\tmyarch" /etc/hosts

## This
mkinitcpio -P

#adding users, and privileges here
adduser -m-g users -G wheel petar
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

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
