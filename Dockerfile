FROM ubuntu:18.04

# Install required packages
RUN apt-get update && apt-get install -y --no-install-recommends \
        bc \
        binutils-arm-none-eabi \
        bison \
        bsdmainutils \
        build-essential \
        cmake \
        file \
        flex \
        gcc-arm-none-eabi \
        gdb \
        git \
        less \
        libglib2.0-dev \
        libpixman-1-0 \
        libpixman-1-dev \
        libpython2.7 \
        pkg-config \
        python \
        python3 \
        python3-venv \
        telnet \
        tio \
        u-boot-tools \
        usbutils \
        vim \
        wget \
    && rm -rf /var/lib/apt/lists/*

# Install ARM GDB, left out of Ubuntu 18 packages
RUN mkdir -p packages && cd packages && \
    wget -q http://mirrors.kernel.org/ubuntu/pool/universe/g/gdb-arm-none-eabi/gdb-arm-none-eabi_7.10-1ubuntu3+9_amd64.deb && \
    wget -q http://mirrors.kernel.org/ubuntu/pool/main/r/readline6/libreadline6_6.3-8ubuntu2_amd64.deb && \
    dpkg -i libreadline6_6.3-8ubuntu2_amd64.deb && \
    dpkg -i gdb-arm-none-eabi_7.10-1ubuntu3+9_amd64.deb && \
    cd ..

# Compile QEMU from downloaded package
ARG QEMU_VERSION=4.1.0
WORKDIR /qemu-install
RUN extractedDirName="qemu-${QEMU_VERSION}" && \
    qemuFileName="qemu-${QEMU_VERSION}.tar.xz" && \
    packageUrl="https://download.qemu.org/${qemuFileName}" && \
    wget --no-check-certificate --quiet ${packageUrl} && \
    tar xf ${qemuFileName} && \
    mkdir -p ${extractedDirName}/bin && \
    cd ${extractedDirName}/bin && \
    ../configure \
        --prefix=/opt/qemu \
        --python=python3 \
        --disable-user \
        --disable-bluez \
        --disable-vnc \
        --disable-gtk \
        --disable-sdl \
        --enable-system \
        --target-list="arm-softmmu aarch64-softmmu" && \
    make && \
    make install
ENV PATH="/opt/qemu/bin:${PATH}"

# Configure python venv
WORKDIR /python
RUN python3 -m venv venv && \
    ./venv/bin/pip3 install --upgrade pip && \
    ./venv/bin/pip3 install --upgrade setuptools && \
    ./venv/bin/pip3 install --upgrade gdbgui

# Download U-Boot and compile it for imx7 board
ARG UBOOT_VERSION=2019.07
WORKDIR /u-boot
RUN ubootName="u-boot-${UBOOT_VERSION}" && \
    wget --quiet ftp://ftp.denx.de/pub/u-boot/${ubootName}.tar.bz2 && \
    tar -xf ${ubootName}.tar.bz2 && \
    cd ${ubootName} && \
    make CROSS_COMPILE=arm-none-eabi- mx7dsabresd_config && \
    make CROSS_COMPILE=arm-none-eabi- && \
    arm-none-eabi-objdump -S u-boot > u-boot.S
COPY run-uboot.sh .

# Set workspace directory
ARG WORKDIR=/workspace
WORKDIR ${WORKDIR}

# Copy source of the application
COPY app ${WORKDIR}/app

# Build the C hello world application on different targets
RUN bash -x app/build.sh zybo a9
RUN bash -x app/build.sh qemu-a7 a7
RUN bash -x app/build.sh qemu-a9 a9

COPY gdb.script ${WORKDIR}/
COPY gdbgui.sh ${WORKDIR}/
