#!/bin/sh
# Build the C hello world application

set -e

BOARD_NAME=$1
PROCESSOR_TYPE=$2

appDir=`realpath app`
buildDir=${appDir}/build-${BOARD_NAME}
mkdir ${buildDir}
cd ${buildDir}

# Configure the directory to build
cmake   -DTOOLCHAIN_DIR=/usr \
        -DCPU_CORTEX_TYPE=cortex-${PROCESSOR_TYPE} \
        -DLINK_FILE=${BOARD_NAME}.lds \
        -DCMAKE_BUILD_TYPE=Debug \
        ${appDir}

# Compile source in objects and link objects in ELF application
make VERBOSE=1 -j1

# Dump the disassembly
arm-none-eabi-objdump -S embeddedhello > embeddedhello.S

# Convert ELF application to binary application
arm-none-eabi-objcopy \
    --enable-deterministic-archives \
    --output-target binary \
    embeddedhello \
    embeddedhello.bin

# Add a header to binary application to boot it with U-Boot
# TODO mkimage
