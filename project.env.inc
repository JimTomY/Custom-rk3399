
# 交叉编译工具链路径
export PATH=$PATH:/home/yangao/source/gcc-arm-none-eabi/gcc-arm-none-eabi-10.3-2021.10/bin:/home/yangao/source/aarch64-none-linux-gnu/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu/bin

export CROSS_COMPILE=aarch64-linux-gnu-


# 工程文件路径
export PROJECT_TOP_DIR=$PWD

export SOURCE_TOP_DIR=$PROJECT_TOP_DIR/../../

export PORTING_DIR=$PROJECT_TOP_DIR/porting


# arm-trust路径
export ARM_TRUST_SOURCE_DIR=$SOURCE_TOP_DIR/arm-trusted-firmware

export ARM_TRUST_BUILD_DIR=$PWD/out/arm_trust_build

export ARM_TRUST_PLAT=rk3399


# uboot路径
export LOADER_SOURCE_DIR=$SOURCE_TOP_DIR/u-boot

export LOADER_BUILD_DIR=$PWD/out/loader_build

export LOADER_DEFCONFIG=firefly-rk3399_defconfig


# kernel路径
export KERNEL_SOURCE_DIR=$SOURCE_TOP_DIR/linux

export KERNEL_BUILD_DIR=$PWD/out/kernel_build

export KERNEL_DEFCONFIG=firefly_linux_defconfig

export KERNEL_DTS=rk3399-firefly.dtb

export ARCH=arm64


# busybox路径
export BUSYBOX_SOURCE_DIR=$SOURCE_TOP_DIR/busybox

export BUSYBOX_BUILD_DIR=$PWD/out/busybox_build


# buildroot路径
export BUILDROOT_SOURCE_DIR=$SOURCE_TOP_DIR/buildroot

export BUILDROOT_BUILD_DIR=$PWD/out/buildroot_build

export BUILDROOT_DEFCONFIG=firefly_buildroot_defconfig

export ROOTFS_DIR=$PROJECT_TOP_DIR/target/rootfs_dir


export CTC_MAKE="make -j32"