#!/bin/sh
set -e

/python/venv/bin/gdbgui \
    --gdb /usr/bin/arm-none-eabi-gdb \
    --gdb-args "-x gdb.script" \
    --port 10500 \
    --host 0.0.0.0 \
    --no-browser \
    $@
