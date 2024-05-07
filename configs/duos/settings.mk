CHIP=cv181x
UBOOT_CHIP=cv181x
UBOOT_BOARD=milkv_duos_sd
BOOT_CPU=riscv
ARCH=riscv
DDR_CFG=ddr3_1866_x16
PARTITION_FILE=partition_sd.xml
STORAGE_TYPE=sd

PACKAGES += " duo-pinmux wireless-regdb wpasupplicant cvi-pinmux-cv181x bluez"

IMAGE_ADDITIONS += "aic8800-firmware"
IMAGE_ADDITIONS += "ethernet-leds"
IMAGE_ADDITIONS += "usb-switch"
IMAGE_ADDITIONS += "hciattach-service"