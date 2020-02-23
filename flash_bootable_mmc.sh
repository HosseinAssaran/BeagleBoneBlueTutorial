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
umount ${source}p1
umount ${destination}p1
dd if=/dev/zero of=${destination} bs=1M count=108
sync
dd if=${destination} of=/dev/null bs=1M count=108
/mnt/destination
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
sync
cd ../..
umount /mnt/source
umount /mnt/destination
rmdir /mnt/source
rmdir /mnt/destination
echo "End of make bootable MMC script."
exit 0
