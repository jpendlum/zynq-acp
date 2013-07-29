#!/bin/bash

cp "../../../../openembedded-core/build_zedboard/tmp-eglibc/deploy/images/uImage-zedboard.bin" "uImage.bin"
cp "../build/zynq-ps/SDK/workspace/zynq_fsbl/Debug/zynq_fsbl.elf" .
cp "../../../../openembedded-core/build_zedboard/tmp-eglibc/deploy/images/u-boot.elf" .
cp "../../../../openembedded-core/build_zedboard/tmp-eglibc/deploy/images/uImage-zynq-zedboard-user-peripheral.dtb" "devicetree.dtb"
cp "../build/zedboard.bit" "system.bit"
bootgen -w on -image boot.bif -o i boot.bin
# bootgen requires a file extension, but when need to remove it for the SD card
mv "uImage.bin" "uImage"
