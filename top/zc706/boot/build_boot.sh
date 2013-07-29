#!/bin/bash

cp "../../../../openembedded-core/build_zc706/tmp-eglibc/deploy/images/uImage-zc706.bin" "uImage.bin"
cp "../build/zynq-ps/SDK/workspace/zynq_fsbl/Debug/zynq_fsbl.elf" .
cp "../../../../openembedded-core/build_zc706/tmp-eglibc/deploy/images/u-boot.elf" .
cp "../../../../openembedded-core/build_zc706/tmp-eglibc/deploy/images/uImage-zynq-zc706-user-peripheral.dtb" "devicetree.dtb"
cp "../build/zc706.bit" "system.bit"
bootgen -w on -image boot.bif -o i boot.bin
# bootgen requires a file extension, but when need to remove it for the SD card
mv "uImage.bin" "uImage"
