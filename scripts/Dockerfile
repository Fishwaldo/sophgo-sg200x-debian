FROM debian:sid as builder

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y eatmydata \
    && eatmydata apt-get install -y --no-install-recommends \
        qemu-user-static mtools sbuild-debian-developer-setup \
        binfmt-support gdisk kpartx sbuild \
        parted ca-certificates dh-make \
        autoconf automake autotools-dev bc \
        build-essential cpio curl sudo \
        dosfstools e2fsprogs fdisk flex gawk  \
        git gperf kmod libexpat-dev \
        libgmp-dev libmpc-dev libmpfr-dev libssl-dev \
        libtool mmdebstrap openssl parted \
        patchutils python3 python3-dev \
        python3-setuptools  swig gnupg \
        systemd-container texinfo zlib1g-dev wget arch-test \
        linux-image-generic genimage joe mc zip \
        fakeroot git kernel-wedge quilt ccache flex bison \
        libssl-dev dh-exec rsync libelf-dev bc gcc-riscv64-unknown-elf \
    && git clone --depth 1 https://github.com/milkv-duo/host-tools.git /host-tools \
    && rm -rf /host-tools/gcc/gcc-linaro-6.3.1-2017.05-x86_64_aarch64-elf \
    && rm -rf /host-tools/gcc/gcc-linaro-6.3.1-2017.05-x86_64_aarch64-linux-gnu \
    && rm -rf /host-tools/gcc/gcc-linaro-6.3.1-2017.05-x86_64_arm-linux-gnueabihf 




FROM builder as build_image
WORKDIR /builder
ADD scripts/ /builder/

CMD /bin/bash
