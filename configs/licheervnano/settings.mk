CHIP=sg200x
UBOOT_CHIP=sg2002
UBOOT_BOARD=licheervnano_sd
BOOT_CPU=riscv
ARCH=riscv
DDR_CFG=ddr3_1866_x16
PARTITION_FILE=partition_sd.xml
STORAGE_TYPE=sd

PACKAGES += " wireless-regdb wpasupplicant"

IMAGE_ADDITIONS += "aic8800-firmware"