#!/usr/bin/env tclsh

#
# SweetAda OpenOCD code download.
#
# Copyright (C) 2020-2024 Gabriele Galeotti
#
# This work is licensed under the terms of the MIT License.
# Please consult the LICENSE.txt file located in the top-level directory.
#

#
# Arguments:
# none
#
# Environment variables:
# SWEETADA_PATH
# LIBUTILS_DIRECTORY
# OPENOCD_PREFIX
# ELFTOOL
# KERNEL_OUTFILE
#

################################################################################
# Script initialization.                                                       #
#                                                                              #
################################################################################

set SCRIPT_FILENAME [file tail $argv0]

################################################################################
#                                                                              #
################################################################################

source [file join $::env(SWEETADA_PATH) $::env(LIBUTILS_DIRECTORY) library.tcl]
source [file join $::env(SWEETADA_PATH) $::env(LIBUTILS_DIRECTORY) libopenocd.tcl]

################################################################################
# Main loop.                                                                   #
#                                                                              #
################################################################################

set OPENOCD_PREFIX  $::env(OPENOCD_PREFIX)
set OPENOCD_CFGFILE [file join $::env(SWEETADA_PATH) $::env(PLATFORM_DIRECTORY) openocd.cfg]
set ELFTOOL         $::env(ELFTOOL)
set KERNEL_OUTFILE  [file join $::env(SWEETADA_PATH) $::env(KERNEL_OUTFILE)]
set START_SYMBOL    _start

if {[lindex $argv 0] eq "-server"} {
    set platform [platform_get]
    if {$platform eq "windows"} {
        set OPENOCD_EXECUTABLE [file join $OPENOCD_PREFIX bin openocd.exe]
        exec cmd.exe /C START "OpenOCD " "$OPENOCD_EXECUTABLE" -f "$OPENOCD_CFGFILE" &
    } elseif {$platform eq "unix"} {
        set OPENOCD_EXECUTABLE [file join $OPENOCD_PREFIX bin openocd]
        # __FIX__
        # if this script is called from Makefile, and the output is redirected
        # on a tee pipe (menu-dialog.sh), then the script hangs because tee
        # seems to wait on an inherited stdout file descriptor, which is kept
        # opened by the xterm sub-process; have we to re-open it?
        close stdout
        exec xterm -hold -e "$OPENOCD_EXECUTABLE" -f "$OPENOCD_CFGFILE" &
    } else {
        puts stderr "$SCRIPT_FILENAME: *** Error: platform not recognized."
        exit 1
    }
    exit 0
}

# local OpenOCD server
openocd_rpc_init 127.0.0.1 6666

if {[lindex $argv 0] eq "-shutdown"} {
    openocd_rpc_tx "shutdown"
    exit 0
}

if {[catch {exec $ELFTOOL -c findsymbol=$START_SYMBOL $KERNEL_OUTFILE} result] eq 0} {
    set START_ADDRESS [format "0x%08X" $result]
} else {
    puts stderr "$SCRIPT_FILENAME: *** Error: no symbol $START_SYMBOL or no $KERNEL_OUTFILE file available."
    openocd_rpc_disconnect
    exit 1
}

# 1) restart on-board firmware, hard reset (needs complete re-initialization)
#reset init
#resume 0
# 2) download SweetAda, avoid resetting RAM
#soft_reset_halt
#load_image .../kernel.o
#verify_image .../kernel.o 0
#resume 0

openocd_rpc_tx "soft_reset_halt"
openocd_rpc_rx
msleep 1000
openocd_rpc_tx "load_image $KERNEL_OUTFILE"
openocd_rpc_rx
openocd_rpc_tx "verify_image $KERNEL_OUTFILE 0\n"
openocd_rpc_rx
openocd_rpc_tx "resume 0"
openocd_rpc_rx

openocd_rpc_disconnect

exit 0

