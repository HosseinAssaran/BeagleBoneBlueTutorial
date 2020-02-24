#!/bin/sh

#This script is for beagle bone to build a bootable eMMC and copy sdcard boot contents into  it.
#It can be run after booting the kernel wiht sd card.

function pause(){
   read -p "$*"
}

if [ -z "$1" ] || [ -z "$2" ]
then
    echo "
Usage: $0 <source-device> <destination-device>
Example: $0 /dev/mmcblk0 /dev/mmcblk1
"
    exit 1
fi
ls $1
if [ $? -ne 0 ]
then
    echo "The $1 device is not available."
    exit 1
fi
ls $2
if [ $? -ne 0 ]
then
    echo "The $2 device is not available."
    exit 1
fi
source=$1
destination=$2
root_device=$(cat /proc/cmdline | awk -F'root=' '{print $2}' | awk '{print $1}')
if [ "$root_device" = "$destination"p2 ]
then
    echo "You can't copy on mounted device as root"
    exit 1
fi
umount ${source}p1
umount ${destination}p1
umount ${source}p2
umount ${destination}p2
dd if=/dev/zero of=${destination} bs=1M count=108
sync
dd if=${destination} of=/dev/null bs=1M count=108
sync
echo -e "o\nn\np\n1\n\n+200M\na\n1\nt\ne\nn\np\n2\n\n\nw\n" | fdisk $destination ; fdisk -l $destination
mkfs.vfat -F 16 ${destination}p1
mkfs.ext2 ${destination}p2
mkdir -p /mnt/source
mkdir -p /mnt/destination
umount /mnt/source
umount /mnt/destination
mount ${source}p1 /mnt/source
mount ${destination}p1 /mnt/destination
cd /mnt/source
cp MLO u-boot.img uEnv.txt /mnt/destination
if [ "$source" = "/dev/mmcblk0" ]
then
    sed -E -i -e 's/uenvcmd=run.*/uenvcmd=run uenvcmd_mmc1/' /mnt/destination/uEnv.txt
elif [ "$source" = "/dev/mmcblk1" ]
then
    sed -E -i -e 's/uenvcmd=run.*/uenvcmd=run uenvcmd_mmc0/' /mnt/destination/uEnv.txt
else
    echo "source is not valid"
    exit 1
fi
sync
cd ../..
umount /mnt/source
umount /mnt/destination
mount ${source}p2 /mnt/source
mount ${destination}p2 /mnt/destination
cd /mnt/source
cp -r ./* /mnt/destination
sync
cd ../..
umount /mnt/source || umount -l /mnt/source
umount /mnt/destination  || umount -l /mnt/destination
rmdir /mnt/source
rmdir /mnt/destination
echo "End of make bootable MMC script."
exit 0
