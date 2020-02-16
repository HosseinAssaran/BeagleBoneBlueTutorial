#!/bin/bash

# This script download zlib and dropbear source code, then configure and build them.
# This script at now just work with ubuntu toolchain "selection 2"
# Then Enter "2" when you asked to select the toolchain.
# It has and issue with "armv7-eabihf--uclibc--stable-2018.11-1 toolchain" that I don't find yet.
# While running maybe it asks you for password to install toolchain.

echo Script to download and Install zlib and dropbear
mkdir -p /tmp/test
cd /tmp/test
rm -rf zlib-1.2.11
rm -rf dropbear-2019.78
rm -rf build
echo Which toolchain to use?
echo "Enter '1' for armv7-eabihf--uclibc--stable-2018.11-1"
echo "Enter '2' for ubuntu default: gcc-arm-linux-gnueabihf"
read toolchain
if [ $toolchain -eq '1' ]; then
    FILE=~/x-tools/armv7-eabihf--uclibc--stable-2018.11-1/bin/arm-linux-gcc
    export PATH=~/x-tools/armv7-eabihf--uclibc--stable-2018.11-1/bin/:$PATH
    COMPILER_PREFIX=arm-linux
    if test -f "$FILE"; then
       echo "$FILE exist"
    else
       cd /tmp/test
       FILE=/test/tmp/armv7-eabihf--uclibc--stable-2018.11-1.tar.bz2
       if test -f "$FILE"; then
          echo "$FILE exist"
       else
          wget https://toolchains.bootlin.com/downloads/releases/toolchains/armv7-eabihf/tarballs/armv7-eabihf--uclibc--stable-2018.11-1.tar.bz2          
       fi
       mkdir ~/x-tools       
       tar xvf armv7-eabihf--uclibc--stable-2018.11-1.tar.bz2 -C ~/x-tools
    fi
elif [ $toolchain -eq '2' ]; then
    FILE=/usr/bin/arm-linux-gnueabihf-gcc
    COMPILER_PREFIX=arm-linux-gnueabihf
    if test -f "$FILE"; then
       echo "$FILE exist"
    else
       sudo apt -y install gcc-arm-linux-gnueabihf
    fi
else
    echo not select a correct toolchain
    exit 1
fi

FILE=/tmp/test/zlib-1.2.11.tar.gz
if test -f "$FILE"; then
    echo "$FILE exist"
else
    wget https://www.zlib.net/zlib-1.2.11.tar.gz
fi
tar xvf zlib-1.2.11.tar.gz || exit 1
cd zlib-1.2.11 || exit 1
make distclean || exit 1
CC=$COMPILER_PREFIX-gcc ./configure --prefix /usr || exit 1
make || exit 1
mkdir ../build
make install DESTDIR=../build || exit 1
echo End of installing zlib

cd ..
FILE=/tmp/test/dropbear-2019.78.tar.bz2
if test -f "$FILE"; then
    echo "$FILE exist"
else
    wget https://matt.ucc.asn.au/dropbear/releases/dropbear-2019.78.tar.bz2
fi
tar xf dropbear-2019.78.tar.bz2 || exit 1
cd dropbear-2019.78
./configure --host=$COMPILER_PREFIX --with-zlib=../build/usr --prefix=/usr || exit 1
make -j4 || exit 1
make install DESTDIR=../build  || exit 1


