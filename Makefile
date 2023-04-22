############################################################################
#
# Makefile -- Top level project Makefile.
#

all_targets = arm-trusted-firmware
all_targets += loader
all_targets += linux
all_targets += busybox

all: $(all_targets) package FORCE

package: FORCE
	@if [ -d $(ROOTFS_DIR) ]; then \
		rm -rf $(ROOTFS_DIR); \
	fi; \
	if [ ! -d $(ROOTFS_DIR) ]; then \
		cd $(PROJECT_TOP_DIR)/target; \
		cp -a skeleton rootfs_dir; \
	fi; \
	echo "Package $(ARCH) binaries, please wait..."; \
	cd $(PROJECT_TOP_DIR)/target; \
	echo "Create rootfs binary image..."; \
	fakeroot ./build_rootfs_custom.sh; \
	echo "Generate kernel..."; \
	cd $(KERNEL_BUILD_DIR); \
	$(CTC_MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) rockchip/$(KERNEL_DTS); \
	$(CTC_MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) Image.gz; \
	echo "Create one image..."; \
	cp -f $(KERNEL_BUILD_DIR)/arch/arm64/boot/Image.gz $(PROJECT_TOP_DIR)/target/; \
	cp -f $(KERNEL_BUILD_DIR)/arch/arm64/boot/dts/rockchip/$(KERNEL_DTS) $(PROJECT_TOP_DIR)/target/; \
	cp -f $(KERNEL_BUILD_DIR)/initramfs_data.cpio.lzma $(PROJECT_TOP_DIR)/target/; \
	cd $(PROJECT_TOP_DIR)/target/; \
	./mkimage -f package.its rk3399_its_package; \
	# rm -f Image.gz initramfs_data.cpio.lzma $(KERNEL_DTS); \
	echo "Enjoy It!"


arm-trusted-firmware: FORCE
	@if [ -d $(ARM_TRUST_SOURCE_DIR) ] ; then \
		cd $(ARM_TRUST_SOURCE_DIR); \
		$(CTC_MAKE) CROSS_COMPILE=$(CROSS_COMPILE) PLAT=$(ARM_TRUST_PLAT) O=$(ARM_TRUST_BUILD_DIR); \
	else \
		echo $(ARM_TRUST_SOURCE_DIR); \
	fi

clean_arm-trusted-firmware: FORCE
	@if [ -d $(ARM_TRUST_SOURCE_DIR) ] ; then \
		cd $(ARM_TRUST_SOURCE_DIR); \
		make clean; \
		make distclean; \
	fi


loader: FORCE
	@if [ -d $(LOADER_SOURCE_DIR) ] ; then \
		cd $(PROJECT_TOP_DIR); \
		cp -rf $(PORTING_DIR)/loader-porting/* $(LOADER_SOURCE_DIR); \
		cd $(LOADER_SOURCE_DIR); \
		$(CTC_MAKE) distclean; \
	fi; \
	if [ ! -f $(LOADER_BUILD_DIR)/.config ] ; then \
		cd $(LOADER_SOURCE_DIR); \
		$(CTC_MAKE) ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) mrproper; \
		$(CTC_MAKE) ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) O=$(LOADER_BUILD_DIR) $(LOADER_DEFCONFIG); \
	fi; \
	if [ -f $(ARM_TRUST_SOURCE_DIR)/build/rk3399/release/bl31/bl31.elf ] ; then \
		export BL31=$(ARM_TRUST_SOURCE_DIR)/build/rk3399/release/bl31/bl31.elf; \
		echo "BL31=$(ARM_TRUST_SOURCE_DIR)/build/rk3399/release/bl31/bl31.elf"; \
	else \
		echo "bl31.elf not exist !"; \
	fi; \
	cd $(LOADER_SOURCE_DIR); \
	$(CTC_MAKE) ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) O=$(LOADER_BUILD_DIR); \
	cp -f $(LOADER_BUILD_DIR)/tools/mkimage $(PROJECT_TOP_DIR)/target; \
	cp -f $(LOADER_BUILD_DIR)/idbloader.img $(PROJECT_TOP_DIR)/target; \
	cp -f $(LOADER_BUILD_DIR)/u-boot.itb $(PROJECT_TOP_DIR)/target;	

clean_loader: FORCE
	@if [ -d $(LOADER_BUILD_DIR) ] ; then \
		rm -rf $(LOADER_BUILD_DIR); \
	fi

loader_defconfig:
	@if [ ! -f $(LOADER_BUILD_DIR)/.config ] ; then \
		cd $(PROJECT_TOP_DIR); \
		mkdir -p $(LOADER_BUILD_DIR); \
		make ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) O=$(LOADER_BUILD_DIR) mrproper; \
		make ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) O=$(LOADER_BUILD_DIR) $(LOADER_DEFCONFIG); \
	fi; \
	cd $(LOADER_BUILD_DIR); \
	make menuconfig; \
	make savedefconfig; \
	cp -f defconfig $(PORTING_DIR)/loader-porting/configs/$(LOADER_DEFCONFIG)


linux: FORCE
	@if [ -d $(KERNEL_SOURCE_DIR) ] ; then \
		cd $(KERNEL_SOURCE_DIR); \
		cp -rf $(PORTING_DIR)/linux-porting/* $(KERNEL_SOURCE_DIR); \
		$(CTC_MAKE) ARCH=$(ARCH) mrproper; \
	fi; \
	if [ ! -f $(KERNEL_BUILD_DIR)/.config ] ; then \
		cd $(KERNEL_SOURCE_DIR); \
		mkdir -p $(KERNEL_BUILD_DIR); \
		$(CTC_MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) O=$(KERNEL_BUILD_DIR) mrproper; \
		$(CTC_MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) O=$(KERNEL_BUILD_DIR) $(KERNEL_DEFCONFIG); \
	fi; \
	cd $(KERNEL_BUILD_DIR); \
	$(CTC_MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) rockchip/$(KERNEL_DTS); \
	$(CTC_MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) Image.gz; \
	cp $(KERNEL_SOURCE_DIR)/usr/gen_initramfs.sh $(KERNEL_BUILD_DIR)/usr/gen_initramfs.sh

clean_linux: FORCE
	@rm -rf $(KERNEL_BUILD_DIR)

linux_defconfig:
	@if [ ! -f $(KERNEL_BUILD_DIR)/.config ] ; then \
		cd $(KERNEL_SOURCE_DIR); \
		mkdir -p $(KERNEL_BUILD_DIR); \
		make ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) O=$(KERNEL_BUILD_DIR) mrproper; \
		make ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) O=$(KERNEL_BUILD_DIR) $(KERNEL_DEFCONFIG); \
	fi; \
	cd $(KERNEL_BUILD_DIR); \
	make menuconfig; \
	make savedefconfig; \
	cp -f $(PORTING_DIR)/linux-porting/arch/arm64/configs/$(KERNEL_DEFCONFIG) $(PORTING_DIR)/linux-porting/arch/arm64/configs/$(KERNEL_DEFCONFIG)_backup; \
	cp -f defconfig $(PORTING_DIR)/linux-porting/arch/arm64/configs/$(KERNEL_DEFCONFIG)


busybox: FORCE
	@if [ -d $(BUSYBOX_SOURCE_DIR) ]; then \
		cd $(PROJECT_TOP_DIR); \
		cp -rf $(PORTING_DIR)/busybox-porting/* $(BUSYBOX_SOURCE_DIR); \
	fi; \
	if [ ! -f $(BUSYBOX_BUILD_DIR)/.config ]; then \
		cd $(BUSYBOX_SOURCE_DIR); \
		mkdir -p $(BUSYBOX_BUILD_DIR); \
		$(CTC_MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) O=$(BUSYBOX_BUILD_DIR) distclean; \
		$(CTC_MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) O=$(BUSYBOX_BUILD_DIR) outputmakefile; \
		cp -f config $(BUSYBOX_BUILD_DIR)/.config; \
	fi; \
	cd $(BUSYBOX_BUILD_DIR); \
	$(CTC_MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE)

clean_busybox: FORCE
	@rm -rf $(BUSYBOX_BUILD_DIR)

busybox_defconfig:
	@if [ ! -f $(BUSYBOX_BUILD_DIR)/.config ]; then \
		cd $(BUSYBOX_SOURCE_DIR); \
		mkdir -p $(BUSYBOX_BUILD_DIR); \
		$(CTC_MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) O=$(BUSYBOX_BUILD_DIR) distclean; \
		$(CTC_MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) O=$(BUSYBOX_BUILD_DIR) outputmakefile; \
		cp -f config $(BUSYBOX_BUILD_DIR)/.config; \
	fi; \
	cd $(BUSYBOX_BUILD_DIR); \
	make menuconfig; \
	cp -f .config $(PORTING_DIR)/busybox-porting/config


buildroot: FORCE
	@if [ -d $(BUILDROOT_SOURCE_DIR) ]; then \
		cd $(PROJECT_TOP_DIR); \
		cp -rf $(PORTING_DIR)/buildroot-porting/* $(BUILDROOT_SOURCE_DIR); \
	fi; \
	if [ ! -f $(BUILDROOT_BUILD_DIR)/.config ]; then \
		cd $(BUILDROOT_SOURCE_DIR); \
		mkdir -p $(BUILDROOT_BUILD_DIR); \
		make clean; \
		cp $(BUILDROOT_SOURCE_DIR)/$(BUILDROOT_DEFCONFIG) $(BUILDROOT_BUILD_DIR)/.config; \
		make O=$(BUILDROOT_BUILD_DIR); \
	fi; \
	cd $(BUILDROOT_SOURCE_DIR); \
	make O=$(BUILDROOT_BUILD_DIR) menuconfig; \
	make O=$(BUILDROOT_BUILD_DIR); \
	cd $(BUILDROOT_BUILD_DIR)/target; \
	cp -ar usr $(PROJECT_TOP_DIR)/target/skeleton; \
	cp -ar lib $(PROJECT_TOP_DIR)/target/skeleton; \
	cp -ar lib64 $(PROJECT_TOP_DIR)/target/skeleton

clean_buildroot: FORCE
	@rm -rf $(BUILDROOT_BUILD_DIR)

buildroot_defconfig:
	@if [ ! -f $(BUILDROOT_BUILD_DIR)/.config ]; then \
		cd $(BUILDROOT_SOURCE_DIR); \
		mkdir -p $(BUILDROOT_BUILD_DIR); \
		make clean; \
	fi; \
	cp -f $(PORTING_DIR)/buildroot-porting/$(BUILDROOT_DEFCONFIG) $(PORTING_DIR)/buildroot-porting/configs/$(BUILDROOT_DEFCONFIG)_backup; \
	cd $(BUILDROOT_SOURCE_DIR); \
	make O=$(BUILDROOT_BUILD_DIR) menuconfig; \
	make savedefconfig; \
	cp -f defconfig $(PORTING_DIR)/buildroot-porting/$(BUILDROOT_DEFCONFIG)

.PHONY: FORCE
FORCE: