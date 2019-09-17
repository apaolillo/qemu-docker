FROM ubuntu:18.04

ARG QEMU_VERSION=4.1.0

# Install required packages
RUN apt-get update && apt-get install -y --no-install-recommends \
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

# Compile qemu from downloaded package
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

# Set workspace directory
ARG WORKDIR=/workspace
WORKDIR ${WORKDIR}
