# Custom-rk3399

Custom rk3399 develop script

# upgrade uboot
tftpboot 0x20000000 idbloader.img; mmc write 0x20000000 0x40 0x1bc0; tftpboot 0x22000000 u-boot.itb; mmc write 0x22000000 0x4000 0x2000 \r\n


# tftp fit image
tftpboot 0x10000000 rk3399_its_package; bootm \r\n


# tftp image
tftpboot 0x22000000 Image; tftpboot 0x44000000 uramdisk.image.gz; tftpboot 0x30000000 rk3399-firefly.dtb; booti 0x22000000 0x44000000 0x30000000 \r\n
