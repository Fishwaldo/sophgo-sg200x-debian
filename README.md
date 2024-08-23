# Debian Images for Sophgo cv181x/sg200x based boards 
This repository builds debian sid images for Sophgo cv181x/sg200x based boards such as MilkV Duo256/DuoS and Sipeed LicheeRvNano.

(Note, we don't support the MilkV Duo, as it does not have enough ram to run Debian)

The images aim to be as close to possible to debian best practices as possible

## Flashing the Image

### Duo256, DuoS, and LicheeRVNano
To flash from linux, either build your own image, or download a image from the releases page, and then run the following command:
```
sudo dd if=image/(board)_sd.img of=/dev/sdX bs=4M status=progress
```

From windows, you can use tools such as balena etcher

where the (board)_sd.img is the image file you want to flash, and /dev/sdX is the device you want to flash to.
(if you build for a different board, the image file name will be different)

### DuoS with EMMC
To flash the DuoS with EMMC, you need to use the vendor tools to flash the image to the EMMC. You can follow the
instructions at https://milkv.io/docs/duo/getting-started/duos#emmc-version-firmware-burning but instead of downloading 
the  milkv-duos-emmc-v1.1.0-2024-0410.zip file, you download the duos_emmc.zip from the releases on this repository.

if you already have a image installed, but wish to upgrade, when u-boot loads up, interupt the boot process by pressing any
key and typing the following commands:
```
cvi_update
```

The flashing should then continue


## Image Info
Logins: root/rv and debian/rv

(root login is disabled via SSH, login via debian, and SU to root if needed)

### USB Gadget Support
by default, a rndis interface is started on the USB port, and the IP address is
10.42.0.1 - It also starts a DHCP Server on that interface, so your PC should automatically get an IP address in the 10.42.0.x range

To Disable the rndis interface, you can run the following command:
```
systemctl disable usb-gadget-rndis
```

There is also a option to start a serial port (ACM) interface instead of the rndis interface, to do this, you can run the following command:
```
systemctl disable usb-gadget-rndis
systemctl enable usb-gadget-acm
```

After executing these commands, you need to reboot.

### DuoS - USB Type A Port
After disabling the usb-gadgets, if you want to use the USB Type A Ports, then you need to turn them on:
```
systemctl enable usb-switch
```

and reboot afterwards. 

### Wifi on DuoS/LicheeRVNano
For the LicheeRVNano/DuoS board, Wifi is enabled. To connect to your wifi network, execute the following command and select "Activate a connection" and select your wifi network:
```
nmtui
```

### Ethernet
For Boards with eithernet, they should automatically get a IP address if your network has a DHCP Server. You can configure the 
ethernet port in nmtui

### Camera/ISP/Panel Support
The images are based on the vendor 5.10 kernel, but exclude the following drivers:
- mipi-rx/csi drivers
- mipi-tx/dsi drivers
- TPU Drivers
- Any of the Video Encoding Drivers

(this is mainly due to compatibility reasons with the glibc version in debian and musl version used in the vendor images)

The images, by default, do not allocate any memory for the ION heap, as they are unused in this image, so you get the full memory of each device

### Ardunio/Freertos Support
The images also include the remoteproc and mailbox drivers so you can load up ardunio/freertos images on the small C906 core. 

### Additional Packages
This image also adds the debian repository for https://github.com/Fishwaldo/sophgo-sg200x-packages so you can install additional repositories. The debian repository is hosted at 
https://sophgo.my-ho.st:8443/ which pulls down the compiled debian packages from the above github repository occasionally.


## Building the Image
To build a stock image with no modifications:
```
podman run --privileged -it --rm -v ./configs/:/configs -v ./image:/output ghcr.io/fishwaldo/sophgo-sg200x-debian:mainline make BOARD=licheervnano image
```

Replace the licheervnano with the board you want to build for:
- duo256
- duos
- licheervnano

If you want to create a image for the DuoS with EMMC, you can add "STORAGE_TYPE=emmc" to the make commannd:
```
podman run --privileged -it --rm -v ./configs/:/configs -v ./image:/output ghcr.io/fishwaldo/sophgo-sg200x-debian:master make BOARD=duos STORAGE_TYPE=emmc image
```

The Docker image will build the image and place it in the image directory

addition make targets are available when building:
- image - builds the image
- clean - cleans the build directory
- linux - build a kernel debian package
- fsbl - build the fsbl debain package (that includes cvitek-fsbl, opensbi and u-boot)

## Customizing the Image
The configs directory contains patches, configuration and device tree files that are used to build the image.

The configs/common directory contains the common configuration for all boards, and the configs/licheervnano and configs/duo256 directories contain the board specific configuration.

To add packages to the image, either add the package name in PACKAGES variable of configs/settings.mk or if the packae is specific to a board, add it to the configs/\<board\>/settings.mk file

Patches for the kernel, opensbi, u-boot or fsbl can be placed in configs/common/patches/ or configs/\<board\>/patches/ depending what they are for.

To assist with developing the image, you can get a shell in the docker container by running:
```
docker run --privileged -it --rm -v ./configs/:/configs -v ./image:/output -v ./scripts/:/builder builder /bin/bash
```
inside the container, packages are build in the /builder/ directory, and the rootfs is placed at /rootfs/ directory

# TODO
- DeviceTree Overlay Support
- Add support for the MIPI-CSI/DSI drivers (Sample applications would be in the sophgo-sg200x-packages repository if they do not depend upon a musl libc version)
- Add support for the TPU drivers
- Possibly mainline kernel support via the sophgo linux for-next repositories
