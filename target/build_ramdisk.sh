#!/bin/sh

#
# ramdisk 编译脚本
#

#default path
ROOTFS_BUILD_DIR=$PROJECT_TOP_DIR/target/rootfs_dir
rootfs_dir=$ROOTFS_BUILD_DIR
uramdisk_dir=$PROJECT_TOP_DIR/target
uramdisk_name=$uramdisk_dir/uramdisk.image.gz
genext2fs_dir=$PROJECT_TOP_DIR/target
arch=arm64

make_uramdisk_use_genext2fs(){
        #创建临时变量
        ramdiskName=$uramdisk_dir/ramdisk.image
        ramdiskgz=$uramdisk_dir/ramdisk.gz
        #生成ramdisk文件
        genext2fs -b 1024000 -d $rootfs_dir $ramdiskName
        #压缩ramdisk镜像
        gzip -9 -c $ramdiskName > $ramdiskgz
        #使用mkimage制作uboot启动的ramdisk,添加文件头
        ./mkimage -A arm -T ramdisk -C gzip -d $ramdiskgz $uramdisk_name

        #删除临时文件
        rm $ramdiskName $ramdiskgz
}

make_uramdisk_use_genext2fs
