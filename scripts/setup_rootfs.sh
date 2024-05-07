#!/bin/sh
#
set -ex

BOARD=$(cat /tmp/install/board)
HOSTNAME=$(cat /tmp/install/hostname)


export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true
export LC_ALL=C LANGUAGE=C LANG=C

/var/lib/dpkg/info/base-passwd.preinst install || true
/var/lib/dpkg/info/sgml-base.preinst install || true

mkdir -p /etc/sgml
mount proc -t proc /proc
mount -B sys /sys
mount -B run /run
mount -B dev /dev
#mount devpts -t devpts /dev/pts
dpkg --configure -a

unset DEBIAN_FRONTEND DEBCONF_NONINTERACTIVE_SEEN

#
# Change root password to 'rv'
#
usermod --password "$(echo rv | openssl passwd -1 -stdin)" root

#
# Add a new user debian and its passwd is `rv`
#
mkdir -p /home/debian
useradd --password dummy \
    -G cdrom,floppy,sudo,audio,dip,video,plugdev \
    --home-dir /home/debian --shell /bin/bash debian || true
chown debian:debian /home/debian
# Set password to 'debian'
usermod --password "$(echo rv | openssl passwd -1 -stdin)" debian || true

# Set up fstab
cat > /etc/fstab <<EOF
# <file system> <mount point>   <type>  <options>                 <dump>  <pass>
/dev/root       /               auto    defaults                  1       1
/dev/mmcblk0p1  /boot/          vfat    umask=0077                0       1
EOF

#regenerate SSH keys on first boot
cat > /etc/systemd/system/finalize-image.service <<EOF
[Unit]
Description=Finalize the Image
Before=ssh.service

[Service]
Type=oneshot
ExecStartPre=-/usr/sbin/parted -s -f /dev/mmcblk0 resizepart 2 100%
ExecStartPre=-/usr/sbin/resize2fs /dev/mmcblk0p2
ExecStartPre=-/bin/dd if=/dev/hwrng of=/dev/urandom count=1 bs=4096
ExecStartPre=-/bin/sh -c "/bin/rm -f -v /etc/ssh/ssh_host_*_key*"
ExecStart=/usr/bin/ssh-keygen -A -v
ExecStartPost=/bin/systemctl disable finalize-image

[Install]
WantedBy=multi-user.target
EOF


apt install -y -f /tmp/install/*.deb


# change device tree
echo "===== ln -s dtb files ====="
file_prefix="/usr/lib/linux-image-*"

file_path=$(ls -d $file_prefix)

if [ -e "$file_path" ]; then
  echo "File found: $file_path"
  lib_dir=$file_path
else
  echo "File not found: $file_path"
fi

kernel_image=${lib_dir##*/}

# set default dtb file, please verify your board version
mkdir -p /boot/fdt/${kernel_image}

cp ${lib_dir}/cvitek/*.dtb /boot/fdt/${kernel_image}/


cat /boot/extlinux/extlinux.conf

sed -i -i 's|#U_BOOT_PARAMETERS=".*"|U_BOOT_PARAMETERS="console=ttyS0,115200 earlycon=sbi root=/dev/mmcblk0p2 rootwait rw"|' /etc/default/u-boot
sed -i -e 's|#U_BOOT_SYNC_DTBS=".*"|U_BOOT_SYNC_DTBS="true"|' /etc/default/u-boot
#doing this dance, as in the chroot, / and /boot are same filesystem, so u-boot-update doesn't setup correctly
echo "U_BOOT_FDT_DIR=\"/usr/lib/linux-image-$BOARD-\"" >> /etc/default/u-boot
u-boot-update
sed -i -e 's|fdtdir /usr/lib/|fdtdir /fdt/|' /boot/extlinux/extlinux.conf
sed -i -e 's|linux /boot/|linux /|' /boot/extlinux/extlinux.conf
#sed -i -e 's|append .*|append console=ttyS0,115200 earlycon=sbi root=/dev/mmcblk0p2 rootwait rw |' /boot/extlinux/extlinux.conf
sed -i -e "s|U_BOOT_FDT_DIR=\".*\"|U_BOOT_FDT_DIR=\"/fdt/linux-image-$BOARD-\"|" /etc/default/u-boot


cat /boot/extlinux/extlinux.conf

# Set hostname
cat /tmp/install/hostname > /etc/hostname

# 
cat >> /etc/hosts << EOF
127.0.0.1      ${HOSTNAME} 
EOF

# 
# Enable system services
#
systemctl enable finalize-image.service
if [ -f /tmp/install/systemd-enable ]; then
  systemctl enable `cat /tmp/install/systemd-enable`
fi

# Update source list 

rm -rf /etc/apt/sources.list.d/multistrap-debian.list

apt-key add /tmp/install/public-key.asc

cat > /etc/apt/sources.list <<EOF
deb http://deb.debian.org/debian sid main non-free-firmware
deb https://sophgo.my-ho.st:8443/ debian sophgo
EOF

echo "/boot/uboot.env	0x0000          0x20000" > /etc/fw_env.config
mkenvimage -s 0x20000 -o /boot/uboot.env /etc/u-boot-initial-env


#
# Clean apt cache on the system
#
apt-get clean


rm -rf /var/cache/*
find /var/lib/apt/lists -type f -not -name '*.gpg' -print0 | xargs -0 rm -f
find /var/log -type f -print0 | xargs -0 truncate --size=0
