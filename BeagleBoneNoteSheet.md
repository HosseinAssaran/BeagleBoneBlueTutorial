# Beagle Bone Blue Note Sheet
This note sheet includes my expreinces in working with **Beagle Bone Blue**. I hope it helps you. You can add issue for problems and pull requests are wellcome.

## How to mount distro image files in your host machine:
1. enter `sudo fdisk -l <name.img>`
2. multiply **sector size** by **start of partiion** you need to mount
3. then enter below command by importing result value from previous section
   `sudo mount -o loop,offset=<result-value>,ro <name.img> /mnt`

## Connecting BeagleBone To Internet through usb-device connected to host machine:

### BeagleBone Settings:
1. Edit sudo vi /etc/resolv.conf and add these lines:
```
nameserver 8.8.8.8
nameserver 8.8.4.4
```
2. `sudo route add default gw <host-machine-ip> usb0`

### Host Machine Settings:
1. `echo 1 > /proc/sys/net/ipv4/ip_forward`
2. `ifconfig -a`
2. `iptables --table nat --append POSTROUTING --out-interface <wireless-interface> -j MASQUERADE`
3. `iptables --append FORWARD --in-interface <usb-etherent-interface> -j ACCEPT`

source:  https://elementztechblog.wordpress.com/2014/12/22/sharing-internet-using-network-over-usb-in-beaglebone-black/

## Get Agnstrum Image and clone it to sdcard
1. `wget https://s3.amazonaws.com/angstrom/demo/beaglebone/Angstrom-Cloud9-IDE-GNOME-eglibc-ipk-v2012.12-beaglebone-2013.06.20.img.xz`
2. `tar xvf Angstrom-Cloud9-IDE-GNOME-eglibc-ipk-v2012.12-beaglebone-2013.06.20.img.xz`
3. `dd if=Angstrom-Cloud9-IDE-GNOME-eglibc-ipk-v2012.12-beaglebone-2013.06.20.img of=/dev/mmcblk0` 

## Uboot Commands To Do Manual Boot From SD With Angstrom Image:
1. `load mmc 0:2 0x82000000 /boot/uImage`
2. `load mmc 0:2 0x88000000 /boot/am335x-boneblue.dtb`
3. `setenv bootargs console=ttyO0,115200 root=/dev/mmcblk0p2 rw`
4. `bootm 0x82000000 - 0x88000000`

## Load uEnv.txt From Host Machine With minicom:
1. `sudo minicom`
2. reset the board, press any key and while you are in uboot command line enter `loadx` 
3. then `ctrl+z` and then `s`
4. choose `xmodem` from the menu
5. go to file location in host machine and select `uEnv.txt`
6. note the download address and size
7. enter `env import -t <laod address> <size>`
   example: `env import -t 0x82000000 290`
8. now your defined vars in `uEnv.txt` is  loaded into your uboot environment variables. 

## Recommended load address for beagle bone:
Binary              |DDR Ram Load Address
|-------------------|--------------------|
Linux Kernel        | 0x82000000
DTB or FDT          | 0x88000000
RAMDISK or INITRAMFS| 0x88080000
 
## Boot BeagleBone From Serial Port:
1. Disconnect sd card and micro usb and power board with adapter
2. While board connected over uart0 to PC run minicom
3. Plug power when pressing SD button and release it after power up
4. When you see `C` press `ctrl+a` and then `s` and select xmodem
5. Choose `SPL` pre-built image and hit enter
6. Repeat 4 and 5 step but for `u-boot.img`
7. enter `loadx 0x820000000` and Repeat 4 and 5 steps but for `uImage`
8. enter `loadx 0x880000000` and Repeat 4 and 5 steps but for `am335x-boneblack.dtb`
9. enter `loadx 0x880800000` and Repeat 4 and 5 steps but for `initramfs` 
10.enter `setenv bootargs console=ttyO0,115200 root=/dev/ram0 rw initrd=0x88080000`
11.enter `bootm 0x82000000 0x88080000 0x88000000`

## Get Bootlin uclibc toolchain and install it
1. `wget https://toolchains.bootlin.com/downloads/releases/toolchains/armv7-eabihf/tarballs/armv7-eabihf--uclibc--stable-2018.11-1.tar.bz2`
2. `tar xf armv7-eabihf--uclibc--stable-2018.11-1.tar.bz2 -C ~/x-tools`

## Install Ubuntu toolchain:
1. `sudo apt install gcc-arm-linux-gnueabihf`

## Compile U-boot With uclibc bootlin toolchain:
1. `sudo apt install flex`
2. `export PATH=~/x-tools/armv7-eabihf--uclibc--stable-2018.11-1/bin/:$PATH`
3. `make ARCH=arm CROSS_COMPILE=arm-linux- distclean`
4. `make ARCH=arm CROSS_COMPILE=arm-linux- am335x_evm_config`
5. `make ARCH=arm CROSS_COMPILE=arm-linux- menuconfig`
6. `make ARCH=arm CROSS_COMPILE=arm-linux- -j4`

## Compile and install busybox with Ubuntu toolchain:
1. `wget https://www.busybox.net/downloads/busybox-1.31.1.tar.bz2`
2. `tar xf busybox-1.31.1.tar.bz2`
3. `cd busybox-1.31.1`
4. `make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- defconfig`
5. `make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- menuconfig`
6. `make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- CONFIG_PREFIX=<install_path> install`

## Compile the kernel With Ubuntu toolchain:
1. `sudo apt install lzop`
2. `wget https://github.com/beagleboard/linux/archive/4.14.zip -o linux-4.14.zip`
3. `unzip linux-4.14.zip`
4. `cd linux-4.14`
5. `make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- distclean`
6. `make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- bb.org_defconfig`
7. `make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- menuconfig`
8. `make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- uImage dtbs LOADADDR=0x80008000 -j4` or to build zImage do `make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-`
9. `make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j4 modules`
10. `make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH=<path_of_the_RFS> modules_install`

## Build a linux bootable sdcard:
Copy files to sdcard to boot and run linux from sdcard
1. Build two partiion on sdcard one for boot with fat filesystem and boot flag enabled and another with ext2.
Then Format both and name first partition as **BOOT** and second as **ROOTFS**.
You can use commands below. Assign **$MYDSIK** with your real device file path in `/dev`:
```
MYDISK=/dev/mmcblk1
echo -e "o\nn\np\n1\n\n+200M\na\n1\nt\nc\nn\np\n2\n\n\nw\n" | fdisk $MYDISK ; fdisk -l $MYDISK
sudo mkfs.vfat ${MYDISK}p1
sudo mkfs.ext2 ${MYDISK}p2
sudo mlabel -i ${MYDISK}p1 ::BOOT
sudo e2label ${MYDISK}p2 ROOTFS
```
2. Mount the boot partition on `/mnt`:
```
sudo mount ${MYDISK}p1 /mnt
```
3. copy `MLO` and `u-boot.img` into BOOT partition mounted.
4. umount the boot partition and mount rootfs partition on `/mnt`:
```
sudo umount ${MYDISK}p1
sudo mount ${MYDISK}p2 /mnt
```
5. copy root file system from where installed by busybox into ROOTFS partion
6. make `boot` and `dev` directory in ROOTFS partiotion
7. copy kernel built image from `arch/arm/boot/uImage` into `boot` directory of ROOTFS partition
8. copy device tree file from `arch/arm/boot/dts/am335x-boneblue.dtb` into `boot` directory of ROOTFS partition
9. make `proc` dirctory in the rootfs directory
10. make `etc/init.d` directory in the rootfs directory of beaglebone
11. go rootfs directory and run `sudo nano etc/init.d/rcS` and add below lines
```
#!/bin/sh

echo "Mounting proc"
mount -t proc /proc /proc
```
12.Adding inittab is not nessecary. if you want to add inititab into /etc you can find it in examples/inittab in busybox source folder

## Build uEnv.txt to automate boot from sdcard 
copy these contents to a file named uEnv.txt and copy it into boot partition alongside u-boot.img and MLO
```
console=ttyS0,115200n8
netargs=setenv bootargs console=ttyO0,115200n8 root=/dev/mmcblk0p2 rw rootfstype=ext3 rootwait debug earlyprintk mem=512M
netboot=echo Booting from microSD ...; setenv autoload no ; load mmc 0:2 ${loadaddr} /boot/uImage ; load mmc 0:2 ${fdtaddr} /boot/am335x-boneblue.dtb ; run netargs ; bootm ${loadaddr} - ${fdtaddr}
uenvcmd=run netboot
```

## Boot kernel from network with ethernet over usb-device of beaglebone 

### Host machine:
1. `sudo apt install tftpd-hpa`
2. `sudo chown tftp:tftp /var/lib/tftpboot`
3. `sudo apt install nfs-kernel-server`
4. `sudo nano /etc/exports`
5. add this line
  `/srv/nfs/bbb *(rw,sync,no_root_squash,no_subtree_check)`
6. `sudo mkdir -p /srv/nfs/bbb`
7. copy root file system built with busy box without parent directory into `/srv/nfs/bbb` 
8. `sudo exportfs -arv`
9. `sudo service nfs-kernel-server restart`
10. `nmcli con add type ethernet ifname enxf8dc7a000001 ip4 192.168.9.1/24`
11.  Go to kernel source folder run **make menuconfig** Find the ”USB Gadget precomposed configurations” and set it to * to become static instead of module so that there is `CONFIG_USB_ETH=y` in .config. Then **make** kernel source again.
12. 
   * If you have a **uImage** do:
      - copy kernel built image from `arch/arm/boot/uImage` into `/var/lib/tftpboot`
      - copy device tree file from `arch/arm/boot/dts/am335x-boneblue.dtb` into `/var/lib/tftpboot`
   * And If you have a **zImage** do:
      - `cat arch/arm/boot/zImage arch/arm/boot/dts/am335x-boneblue.dtb > /var/lib/tftpboot/zImage`


### U-boot command:
1. `setenv ethact usb_ether`
2. `setenv usbnet_devaddr f8:dc:7a:00:00:02`
3. `setenv usbnet_hostaddr f8:dc:7a:00:00:01`
4. `set ipaddr 192.168.9.2`
5. `set serverip 192.168.9.1`
6. `tftpboot 0x82000000 ${serverip}:uImage`
7. `tftpboot 0x88000000 ${serverip}:am335x-boneblue.dtb`
8. `set rootpath /srv/nfs/bbb,nolock,wsize=1024,rsize=1024,nfsvers=3 rootwait rootdelay=2`
9. `set bootargs console=ttyO0,115200n8 g_ether.dev_addr=${usbnet_devaddr} g_ether.host_addr=${usbnet_hostaddr} root=/dev/nfs rw nfsroot=${serverip}:${rootpath} ip=${ipaddr}:::::usb0` 
10. `bootm 0x82000000 - 0x88000000`

You can also concatenate all of the above commands in one command and run it in u-boot. I do an example of it but this time with zImage:
```
setenv ipaddr 192.168.9.2;setenv serverip 192.168.9.1;setenv ethact usb_ether;setenv usbnet_devaddr f8:dc:7a:00:00:02;setenv usbnet_hostaddr f8:dc:7a:00:00:01;setenv rootpath /srv/nfs/bbb,nolock,wsize=1024,rsize=1024,nfsvers=3 rootwait rootdelay=3;setenv bootargs console=ttyO0,115200n8 g_ether.dev_addr=${usbnet_devaddr} g_ether.host_addr=${usbnet_hostaddr} root=/dev/nfs rw nfsroot=${serverip}:${rootpath} ip=${ipaddr}:::::usb0;tftpboot ${loadaddr} ${serverip}:zImage;bootz ${loadaddr}
```

Source:
https://bootlin.com/blog/tftp-nfs-booting-beagle-bone-black-wireless-pocket-beagle/

## Boot kernel from network with ethernet over usb-host of beaglebone 
You just need to add usb ethernet adapter to beaglebone.
These steps are for ax88179 to work under u-boot for other devices you can walk through similar steps.

### Host machine:
1. In steps in compile u-boot after entering `make menuconfig` search these two settings and make sure they are enabled and then build u-boot again.
 `USB_HOST_ETHER=y`
 `USB_ETHER_ASIX88179=y`
2. In steps in compile kernel after entering `make menuconfig` search these two settings and make sure they are enabled and then build kernel again.
 `CONFIG_USB_NET_AX88179_178A=y`
 `USB_NET_AX8817X=y`
3. Go through steps 1 to 10 in host machine part of **Boot kernel from network with ethernet over usb-device**
4. copy **u-boot.img** and **MLO** into sdcard boot partiotion
5. copy **uImage** and **am335x-boneblue.dtb** into `/var/lib/tftpboot`
6. `sudo ifconfig <interface-label> 192.168.6.10`

### BeagleBone U-boot command:
1. **Power the board only with 12V adapter not usb cable**
2. press any key to stop booting
3. `usb start`
4. `set ipaddr 192.168.6.20`
5. `ping 192.168.6.10`
6. if you succedd you receive `host 192.168.6.10 is alive` in your terminal.
7. `set serverip 192.168.6.10`
8. `tftpboot 0x82000000 ${serverip}:uImage`
9. `tftpboot 0x88000000 ${serverip}:am335x-boneblue.dtb`
10. `set rootpath /srv/nfs/bbb,nolock,wsize=1024,rsize=1024,nfsvers=3 rootwait rootdelay=5`
11. `set bootargs console=ttyO0,115200n8 root=/dev/nfs rw nfsroot=${serverip}:${rootpath} ip=${ipaddr}`
12. `bootm 0x82000000 - 0x88000000


## Build uEnv.txt to automate boot kernel with ethernet over usb-host of beaglebone 
```
console=ttyO0,115200n8
ipaddr=192.168.6.20
serverip=192.168.6.10
rootpath=/srv/nfs/bbb,nolock,wsize=1024,rsize=1024,nfsvers=3 rootwait rootdelay=5
loadtftp=echo Booting from network ...;tftpboot ${loadaddr} ${serverip}:uImage; tftpboot ${fdtaddr} ${serverip}:am335x-boneblue.dtb
netargs=setenv bootargs console=${console} root=/dev/nfs rw nfsroot=${serverip}:${rootpath} ip=${ipaddr}
uenvcmd=setenv autoload no;usb start; run loadtftp; run netargs; bootm ${loadaddr} - ${fdtaddr}
```

## Build uEnv.txt to automate boot kernel with ethernet over usb-device of beaglebone 
```
console=ttyO0,115200n8
ipaddr=192.168.9.2
serverip=192.168.9.1
ethact=usb_ether
usbnet_devaddr=f8:dc:7a:00:00:02
usbnet_hostaddr=f8:dc:7a:00:00:01
rootpath=/srv/nfs/bbb,nolock,wsize=1024,rsize=1024,nfsvers=3 rootwait rootdelay=3
loadtftp=echo Booting from network ...;tftpboot ${loadaddr} ${serverip}:uImage; tftpboot ${fdtaddr} ${serverip}:am335x-boneblue.dtb
netargs=setenv bootargs console=${console} g_ether.dev_addr=${usbnet_devaddr} g_ether.host_addr=${usbnet_hostaddr} root=/dev/nfs rw nfsroot=${serverip}:${rootpath} ip=${ipaddr}:::::usb0
uenvcmd=setenv autoload no; run loadtftp; run netargs; bootm ${loadaddr} - ${fdtaddr}
```

##  Look up locations of `init` program in order:
Kernel after booting run **init** program as first program ans gives pid 1 to it. Kernel by default search below paths in order to find the **init** program.
1. `init=<location of init  program>` in u-boot 
2. /sbin/init
3. /etc/init
4. /bin/init
5. /bin/sh

## Enable usb device over ethernet driver manually
1. `modprobe g_ether`
2. `sudo ifconfig 192.168.7.2 up`

## Compile a sample program and run
After compiling with toolchain you need copy program wiht needed libs and the linker from toolchain lib directory to lib/ folder of target root file system:
1. write a hello world program with c language and name it `hello.c`
2. `arm-linux-gnueabihf-gcc -o app hello.c`
3. `sudo cp app /srv/nfs/bbb/`
4. `cd /usr/arm-linux-gnueabihf/lib`
5. `sudo cp -P libc.so.6 /srv/nfs/bbb/lib/`
6. `sudo cp -P libc-2.23.so /srv/nfs/bbb/lib/`
7. `sudo cp -P ld* /srv/nfs/bbb/lib/`

## Get uEnv.txt from host machine by ethernet over usb-dvivce and save it over sdcard boot partition: 
```
setenv ethact usb_ether;setenv usbnet_devaddr f8:dc:7a:00:00:02;setenv usbnet_hostaddr f8:dc:7a:00:00:01;set ipaddr 192.168.9.2;set serverip 192.168.9.1;tftpboot ${loadaddr} ${serverip}:uEnv.txt; fatwrite mmc 0:1 ${loadaddr} uEnv.txt ${filesize}
```
## Get MLO from host machine by ethernet over usb-dvivce and save it over sdcard boot partition:  
```
setenv ethact usb_ether;setenv usbnet_devaddr f8:dc:7a:00:00:02;setenv usbnet_hostaddr f8:dc:7a:00:00:01;set ipaddr 192.168.9.2;set serverip 192.168.9.1;tftpboot ${loadaddr} ${serverip}:MLO; fatwrite mmc 0:1 ${loadaddr} MLO ${filesize}
```
## Get u-boot.img from host machine by ethernet over usb-dvivce and save it over sdcard boot partition:  
```
setenv ethact usb_ether;setenv usbnet_devaddr f8:dc:7a:00:00:02;setenv usbnet_hostaddr f8:dc:7a:00:00:01;set ipaddr 192.168.9.2;set serverip 192.168.9.1;tftpboot ${loadaddr} ${serverip}:u-boot.img; fatwrite mmc 0:1 ${loadaddr} u-boot.img ${filesize}
```
## Use uEnv.txt in loadbootenv:
```  
setenv ethact usb_ether;setenv usbnet_devaddr f8:dc:7a:00:00:02;setenv usbnet_hostaddr f8:dc:7a:00:00:01;set ipaddr 192.168.9.2;set serverip 192.168.9.1;loadbootenv=tftpboot ${loadaddr} ${serverip}:uEnv.txt'
```

## To know dependencies of busybox use this command:
arm-linux-ldd rootfs/bin/busybox

## Copy toolchain libs to rootfs libs
1. Go to rootfs directory
2. `sudo apt install gcc-arm-linux-gnueabihf`
3. `arm-linux-gnueabihf-gcc --print-sysroot`
3. `cp -a /usr/arm-linux-gnueabihf/lib/* lib`

## Get zlib source and build and deploy on target with an example program
1. `wget https://www.zlib.net/zlib-1.2.11.tar.gz`
2. `tar xf zlib-1.2.11.tar.gz`
3. `cd zlib-1.2.11.tar.gz`
4. `CC=arm-linux-gnueabihf-gcc ./configure --prefix /usr`
5. `make`
6. `mkdir ../build`
7. `make install DESTDIR=../build`
8. `tree ../build`
9. `mkdir ../zlib-tests`
10. `cp test/example.c ../zlib-tests/`
11. `cd ../zlib-tests/`
12. `arm-linux-gnueabihf-gcc example.c -I ../build/usr/include/ -L ../build/usr/lib/ -lz`
or 
```
export CFLAGS="-I ../build/usr/include"
export LDFLAGS="-L ../build/usr/lib"
arm-linux-gcc example.c $CFLAGS $LDFLAGS -lz
```
or 
```
export PKG_CONFIG_PATH=../build/usr/lib/pkgconfig
export PKG_CONFIG_SYSROOT_DIR=../build
arm-linux-gcc example.c $(pkg-config --cflags --libs zlib)
```
13. `sudo cp -a ../build/usr/lib/libz.so* ../rootfs/lib`
14. `sudo cp a.out ../rootfs`
15. run it on board with command `./a.out`

## Get dropbear source and build and deploy on the target:
### Host machine:
1. `wget https://matt.ucc.asn.au/dropbear/releases/dropbear-2019.78.tar.bz2`
2. `tar xf dropbear-2019.78.tar.bz2`
3. `cd dropbear-2019.78`
4. `./configure --host=arm-linux-gnueabihf --with-zlib=../build/usr --prefix=/usr`
5. `make -j4`
6. `make install DESTDIR=../build`
7. `cd ..`
8. `sudo cp -P build/usr/sbin/dropbear rootfs/usr/sbin/`
9. `sudo cp -P build/usr/bin/d* rootfs/usr/bin/`
10. `mkdir -p rootfs/etc/dropbear`
### BeagleBone linux:
1. `vi /etc/passwd` and enter below content into it:
```
root:x:0:0:root:/root:/bin/sh 
```
2. `passwd` and enter a password
3. `vi /etc/init.d/rcS` and add below contects into it:
```
mkdir /dev/pts
mount -t devpts /dev/pts /dev/pts
```
4. `/usr/sbin/dropbear -FER`
or if you sure about functionality you can add it to `etc/init.d/rcS` like below:
```
/usr/sbin/dropbear -ER
```

source for one problem according work: https://lists.ucc.gu.uwa.edu.au/pipermail/dropbear/2007q2/000583.html

## Displays shared object dependencies
`export PATH=~/x-tools/armv7-eabihf--uclibc--stable-2018.11-1/bin/:$PATH`
`arm-linux-ldd <program>`
## Displays the contents of the file's dynamic section, if it has one.
`arm-linux-readelf -d <program>`
## Display the target libraries directory
`arm-linux-gcc --print-sysroots`
## Discard symbols from object files.
`arm-linux-strip <program>`

## Available RAM for image download
1.`bdinfo` command in u-boot.
2. Safely availabls space ranges from `-> start` address to `sp start` - `0x100000(stack size)` address

source: 
http://software-dl.ti.com/processor-sdk-linux/esd/docs/latest/linux/Foundational_Components_U-Boot.html#available-ram-for-image-download

##Problem in running `make menuconfig`
It needs **gcc** , **ncurese** and **bison** just run `sudo apt install gcc libncurses5-dev bison` and run `make menuconfig` again.


## How to boot from eMMC instead of sd card

### Host Machine
Over host machine you should compile again u-boot with `CONFIG_ENV_FAT_DEVICE_AND_PART=1:1` to save env on your eMMC.
For that I build a new config with this config modified that you can apply to u-boot project.
1. `export PATH=~/x-tools/armv7-eabihf--uclibc--stable-2018.11-1/bin/:$PATH`
2. `git apply boot_from_emmc.patch` 
3. `make ARCH=arm CROSS_COMPILE=arm-linux- distclean`
4. `make ARCH=arm CROSS_COMPILE=arm-linux- am335x_evm_env_store_on_emmc_config`
5. `make ARCH=arm CROSS_COMPILE=arm-linux- -j4`
6. copy created **MLO** and **u-boot.img** and **uEnv.txt** into boot partition of sdcard that you created before.
7. copy `flash_bootable_mmc.sh` into your rootfs.

### Target Machine
1. Insert SD card and press **SD** button to boot the board with sdcard.
2. After booting the kernel from sd card run command below to make eMMC bootable:
`./flash_bootable_mmc.sh /dev/mmcblk0 /dev/mmcblk1`
3. Reboot the board and press any key to stop u-boot from automic booting the kernel.
4. In u-boot shell enter below commands:
```
setenv mmcdev 1
saveenv`
```
6. Remove sd card, reset the board and enjoy booting over eMMC

## How to build a out of tree module
1. download this example:https://github.com/bootlin/training-materials/tree/master/code/hello-param
2. compile it with simple command: `make`

## How to add a hello module to kernel
1. go through steps above [to get kernel 4.14 for beaglebone and compile it](#compile-the-kernel-with-ubuntu-toolchain)
2. then apply this patch to it:
  `0001-Add-test-module-hello-and-new-hello.patch`
3. use `menuconfig`, go to `device driver` option and add new modules as modules not built-in.
4. then compile kenrel and modules again and install them on board
5. you can you use them with the command `modprobe <module-name>` 
6. you can also apply `0002-Use-kernel-api-in-hello-module.patch` to source and then `0003-Use-linkded-list-in-hello-module.patch` and test updates.

## How to build yocto linux for beaglebone blue
1. Clone poky project with command : `git clone -b kirkstone https://git.yoctoproject.org/git/poky --depth=1`
2. Run `source poky/oe-init-build-env`
3. Open `conf/local.conf` with your favourite editor and do below modifications:
   - Uncomment **MACHINE ?= "beaglebone-yocto"**
   - Add `KERNEL_DEVICETREE:append = " am335x-boneblue.dtb` to tell to bitbake to build the beaglebone blue device tree for you
   - Add `PREFERRED_VERSION_linux-yocto = "5.10%"` to tell to bitbake to build the version 5.10 of kernel. **at now it doesn't work with 5.15**
4. Run `bitbake core-image-minimal` to build linux image
5. Run the below command to copy the image to your sd card:
```
sudo bmaptool copy --bmap tmp/deploy/images/beaglebone-yocto/core-image-minimal-beaglebone-yocto.wic.bmap tmp/deploy/images/beaglebone-yocto/core-image-minimal-beaglebone-yocto.wic /dev/mmcblk0
```
## How to set yocto linux to use nfs server
1. Do **Linux kernel configuration** mentioned in the document [https://bootlin.com/doc/training/embedded-linux-bbb/embedded-linux-bbb-labs.pdf] and compile
2. Do what is said in part **Lab2: Advanced Yocto configuration** in [https://bootlin.com/doc/training/yocto/yocto-labs.pdf]

**Another way:** you can use the meta-custom layer [https://github.com/HosseinAssaran/meta-custom-yoctotraining.git](here) and everything has been done for you. You just need to define beaglebone-yocto as MACHINE in your **local.conf** and you get the image working with /nfs directory on your host machine.


## How to set yocto linux to run from tftp with nfs root
1. Do what ever you did above except modifying **extlinux.conf**
2. Add **uEnv.txt** to boot partition of your sd card and fill it with below contents:
   ```
   console=ttyO0,115200n8
   ipaddr=192.168.0.100
   serverip=192.168.0.1
   usbnet_devaddr=f8:dc:7a:00:00:02
   usbnet_hostaddr=f8:dc:7a:00:00:01
   netargs=setenv bootargs console=${console} root=/dev/nfs ip=${ipaddr}:::::usb0 g_ether.dev_addr=${usbnet_devaddr}       g_ether.host_addr=${usbnet_hostaddr} nfsroot=${serverip}:/nfs,nfsvers=3,tcp rootwait rw
   bootcmd=tftp 0x81000000 zImage; tftp 0x82000000 am335x-boneblue.dtb; bootz 0x81000000 - 0x82000000
   uenvcmd=run netargs; run bootcmd
```

> Written with H.Assaran

