#!/bin/sh
set -o errexit

ROOTFS_BUILD_DIR=$PROJECT_TOP_DIR/target/rootfs_dir

busybox_build_dir=$BUSYBOX_BUILD_DIR
rootfs_dir=$ROOTFS_BUILD_DIR
tmp_file=$(mktemp)

# delete rootfs_dir
# if [ -d $rootfs_dir ]; then
#     rm -rf $rootfs_dir
# fi

# make filesystem dir
install -d -m 755 ${rootfs_dir}/bin
install -d -m 755 ${rootfs_dir}/dev
install -d -m 755 ${rootfs_dir}/etc
install -d -m 755 ${rootfs_dir}/lib
install -d -m 755 ${rootfs_dir}/mnt
install -d -m 755 ${rootfs_dir}/proc
install -d -m 755 ${rootfs_dir}/root
install -d -m 755 ${rootfs_dir}/sbin
install -d -m 755 ${rootfs_dir}/sys
install -d -m 755 ${rootfs_dir}/tmp
install -d -m 755 ${rootfs_dir}/usr
install -d -m 755 ${rootfs_dir}/usr/bin
install -d -m 755 ${rootfs_dir}/usr/lib
install -d -m 755 ${rootfs_dir}/usr/sbin

# make node
mknod -m 666 ${rootfs_dir}/dev/null c 1 3
mknod -m 600 ${rootfs_dir}/dev/zero c 1 5
mknod -m 600 ${rootfs_dir}/dev/random c 1 8
mknod -m 600 ${rootfs_dir}/dev/urandom c 1 9
mknod -m 600 ${rootfs_dir}/dev/console c 5 1
mknod -m 600 ${rootfs_dir}/dev/ttyS0  c 4 64

# copy busybox build
install -c -m 755 ${busybox_build_dir}/busybox ${rootfs_dir}/bin
ln -sf /bin/busybox ${rootfs_dir}/bin/sh
ln -sf /bin/busybox ${rootfs_dir}/bin/ash
ln -sf /bin/busybox ${rootfs_dir}/bin/login
ln -sf /bin/busybox ${rootfs_dir}/sbin/init
ln -sf /bin/busybox ${rootfs_dir}/sbin/mount
ln -sf /bin/busybox ${rootfs_dir}/sbin/getty
ln -sf /proc/mounts ${rootfs_dir}/etc/mtab

# touch /etc/inittab
cat > ${rootfs_dir}/etc/inittab << EOF
# this is run first except when booting in single-user mode.
::sysinit:/etc/init.d/rcS
# /bin/sh invocations on selected ttys
::respawn:-/bin/sh
# Start an "askfirst" shell on the console (whatever that may be)
::askfirst:-/bin/sh
# Stuff to do when restarting the init process
::restart:/sbin/init
# Stuff to do before rebooting
::ctrlaltdel:/sbin/reboot
::shutdown:/sbin/swapoff -a
EOF

# touch rcS
mkdir ${rootfs_dir}/etc/init.d
cat > ${rootfs_dir}/etc/init.d/rcS << EOF
#!/bin/sh
#This is the first script called by init process
/bin/busybox --install -s
/bin/mount -a
# echo /sbin/mdev>/proc/sys/kernel/hotplug
mdev -s
EOF
chmod 755 ${rootfs_dir}/etc/init.d/rcS

# touch fstab
cat > ${rootfs_dir}/etc/fstab << EOF
#device     mount-point     type         options       dump     fsck order
proc        /proc           proc         defaults        0        0
sysfs       /sys            sysfs        defaults        0        0
devtmpfs    /dev            devtmpfs     defaults        0        0
EOF

# touch profile
cat > ${rootfs_dir}/etc/profile  << EOF
#!/bin/sh
export HOSTNAME=farsight
export USER=root
export HOME=root
export PS1="[$USER@$HOSTNAME \W]\# "
PATH=/bin:/sbin:/usr/bin:/usr/sbin
LD_LIBRARY_PATH=/lib:/usr/lib:$LD_LIBRARY_PATH
export PATH LD_LIBRARY_PATH
EOF

# touch init
cat > ${rootfs_dir}/init  << EOF
#!/bin/sh
# devtmpfs does not get automounted for initramfs
exec 0</dev/console
exec 1>/dev/console
exec 2>/dev/console
exec /sbin/init "$@"
EOF
chmod 755 ${rootfs_dir}/init

# cd $ROOTFS_BUILD_DIR
# find ./* | cpio -H newc -o > ../rootfs.cpio
# gzip ../rootfs.cpio

# make initramfs_data.cpio.lzma
cd $PROJECT_TOP_DIR/target
KERNEL_DIR=$KERNEL_SOURCE_DIR
KERNEL_BUILD_DIR=$KERNEL_BUILD_DIR
kernel_dir=$KERNEL_DIR
kbuild_dir=$KERNEL_BUILD_DIR
rm -f ${kbuild_dir}/initramfs_data.cpio.lzma
cd ${kbuild_dir}
${kbuild_dir}/usr/gen_initramfs.sh -u squash -g squash ${rootfs_dir} > initramfs_data.cpio
lzma -9 initramfs_data.cpio
# ${kbuild_dir}/usr/gen_init_cpio temp | xz -F lzma -f -9 > ${kbuild_dir}/usr/initramfs_data.cpio.lzma
rm -f ${kbuild_dir}/usr/initramfs_data.o
rm -f ${tmp_file}