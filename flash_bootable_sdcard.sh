#!/bin/bash

# This script is for building a linux bootable sd card for beaglebone.
# This script is tested over Ubuntu 18.04.3 for other system may be needs changes

pause(){
   read -p "$*"
}

unmount_device_with_care(){
    umount $* 2>&1 | grep busy
    if [ $? -eq 0 ]
    then
        echo "The selected device is busy at now and is not possible to unmount it."
        exit 1
    fi
}

if ! id | grep -q root; then
	echo "must be run as root"
	exit
fi
if [ -z "$1" ]
then
    echo "
Usage: $0 <destination-device>
Example: $0 /dev/mmcblk1
"
    exit 1
fi
ls $1 >/dev/null
if [ $? -ne 0 ]
then
    echo "The $1 device is not available."
    exit 1
fi
destination=$1
echo "destination is ${destination}"
result=$(lsblk $destination -o NAME,HOTPLUG | grep ${destination:5} | awk '{print $2}')
#echo "The result of checking for hot-plug device is $result"
if [[ "$result" != "1"* ]]
then 
    echo "This device is not hot plug and is not possible to flash it."
    exit 1
fi
root_device=$(cat /proc/cmdline | awk -F'root=' '{print $2}' | awk '{print $1}')
echo "root device is $root_device"
if [[ "$root_device" == "UUID="* ]]
then 
    root_device=$(blkid -U "${root_device:5}")
fi
echo "root device is $root_device"
if [[ "$root_device" == "$destination"* ]]
then
    echo "You can't flash on / mounted device"
    exit 1
fi
echo "Successfull"
read -e -p "u-boot directory path:" U_BOOT_PATH
read -e -p "kernel directory path:" KERNEL_PATH
read -e -p "rootfs directory path:" ROOTFS_PATH
read -e -p "eEnv.txt file path:" UENV_FILE_PATH
U_BOOT_PATH="${U_BOOT_PATH/#\~/$HOME}"
KERNEL_PATH="${KERNEL_PATH/#\~/$HOME}"
ROOTFS_PATH="${ROOTFS_PATH/#\~/$HOME}"
UENV_FILE_PATH="${UENV_FILE_PATH/#\~/$HOME}"
if [ ! -d "$U_BOOT_PATH" ]
then 
    echo "The u-boot path you defined is not existed."
    exit 1
fi
if [ ! -d "$KERNEL_PATH" ]
then 
    echo "The kernel path you defined is not existed."
    exit 1
fi
if [ ! -d "$ROOTFS_PATH" ]
then 
    echo "The rootfs path you defined is not existed."
    exit 1
fi
if [ ! -f "$UENV_FILE_PATH" ]
then 
    echo "The uEnv.txt file path you defined is not existed."
    exit 1
fi
[[ "${U_BOOT_PATH}" != */ ]] && U_BOOT_PATH="${U_BOOT_PATH}/"
[[ "${KERNEL_PATH}" != */ ]] && KERNEL_PATH="${KERNEL_PATH}/"
[[ "${ROOTFS_PATH}" != */ ]] && ROOTFS_PATH="${ROOTFS_PATH}/"
echo "The u-boot path is $U_BOOT_PATH"
echo "The kernel path is $KERNEL_PATH"
echo "The rootfs path is $ROOTFS_PATH"
echo "The uEnv.txt file path is $UENV_FILE_PATH"
unmount_device_with_care ${destination}*
dd if=/dev/zero of=${destination} bs=1M count=108
sync
dd if=${destination} of=/dev/null bs=1M count=108
sync
echo -e "o\nn\np\n1\n\n+200M\na\n1\nt\ne\nn\np\n2\n\n\nw\n" | fdisk $destination ; fdisk -l $destination
parts=($(ls ${destination}?*))
echo "Partition 1 is ${parts[0]}"
echo "Partition 2 is ${parts[1]}"
mkfs.vfat -F 16 ${parts[0]}
mkfs.ext2 ${parts[1]}
mlabel -i ${parts[0]} ::BOOT
e2label ${parts[1]} ROOTFS
mkdir -p /mnt/destination
unmount_device_with_care /mnt/destination
mount ${parts[0]} /mnt/destination
cp ${U_BOOT_PATH}MLO ${U_BOOT_PATH}u-boot.img /mnt/destination
cp $UENV_FILE_PATH /mnt/destination/uEnv.txt
sed -E -i -e 's/uenvcmd=run.*/uenvcmd=run uenvcmd_mmc0/' /mnt/destination/uEnv.txt
sync
unmount_device_with_care /mnt/destination
mount ${parts[1]} /mnt/destination
cp -r ${ROOTFS_PATH}* /mnt/destination
mkdir -p /mnt/destination/boot
cp ${KERNEL_PATH}arch/arm/boot/uImage /mnt/destination/boot
cp ${KERNEL_PATH}arch/arm/boot/dts/am335x-boneblue.dtb /mnt/destination/boot
mkdir /mnt/destination/proc
mkdir /mnt/destination/dev
mkdir -p /mnt/destination/etc/init.d
echo "#/bin/sh                                     

echo \"Mounting proc\"
mount -t proc /proc /proc" > /mnt/destination/etc/init.d/rcS
sync
umount /mnt/destination  || umount -l /mnt/destination
rmdir /mnt/destination
echo "End of make bootable sdcard script."
exit 0
