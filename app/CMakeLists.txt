
cmake_minimum_required(VERSION 3.10)
project(embeddedhello C ASM)
#enable_language(ASM${ASSEMBLY_DIALECT})

include(cmake/cross_compile.cmake)

set(APP_SRCS
    src/startup.S
    src/hello.c
)

if("${CPU_CORTEX_TYPE}" STREQUAL "cortex-a7") # TODO put proper option
    list(APPEND APP_SRCS
            src/imx_uart.c
    )
    set(QEMU_MACHINE mcimx7d-sabre)
    set(QEMU_NB_CORES 2)
elseif("${CPU_CORTEX_TYPE}" STREQUAL "cortex-a9")
    list(APPEND APP_SRCS
            src/zynq_uart.c
    )
    set(QEMU_MACHINE xilinx-zynq-a9)
    set(QEMU_NB_CORES 1)
else()
    message(FATAL_ERROR "Unknown CPU_CORTEX_TYPE: ${CPU_CORTEX_TYPE}")
endif()
set(EXEC_PATHNAME ${CMAKE_BINARY_DIR}/${PROJECT_NAME})
set(QEMU_KERNEL_IMAGE ${EXEC_PATHNAME}.bin)

configure_file(
    ${CMAKE_SOURCE_DIR}/run-qemu.sh.in
    ${CMAKE_BINARY_DIR}/run-qemu.sh
)

set(CMAKE_EXE_LINKER_FLAGS "-T ${CMAKE_SOURCE_DIR}/link/${LINK_FILE} -nostdlib")

add_executable(${PROJECT_NAME} ${APP_SRCS})
