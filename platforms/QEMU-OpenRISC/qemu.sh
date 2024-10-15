#!/usr/bin/env sh

#
# QEMU-OpenRISC (QEMU emulator).
#
# Copyright (C) 2020-2024 Gabriele Galeotti
#
# This work is licensed under the terms of the MIT License.
# Please consult the LICENSE.txt file located in the top-level directory.
#

#
# Arguments:
# -debug
#
# Environment variables:
# OSTYPE
# PLATFORM_DIRECTORY
# KERNEL_OUTFILE
# GDB
#

################################################################################
# Script initialization.                                                       #
#                                                                              #
################################################################################

SCRIPT_FILENAME=$(basename "$0")

################################################################################
# tcpport_is_listening()                                                       #
#                                                                              #
# $1 = port                                                                    #
# $2 = timeout in 1 s units                                                    #
# $3 = error message prefix (empty = no message); example: "*** Error"         #
################################################################################
tcpport_is_listening()
{
_time_start=$(date +%s)
while true ; do
  case ${OSTYPE} in
    darwin) _port_listening=$(netstat -a -n -t | grep -c -e "^tcp4.*127.0.0.1.$1.*LISTEN.*\$") ;;
    *)      _port_listening=$(netstat -l -t --numeric-ports | grep -c -e "^tcp.*localhost:$1.*LISTEN.*\$") ;;
  esac
  [ "${_port_listening}" -eq 1 ] && break
  if [ $2 -gt 0 ] ; then
    _time_current=$(date +%s)
    if [ $((_time_current-_time_start)) -gt $2 ] ; then
      if [ "x$3" != "x" ] ; then
        printf "%s\n" "$3: timeout waiting for port $1." 1>&2
      fi
      return 1
    fi
  fi
  sleep 1
done
return 0
}

################################################################################
# Main loop.                                                                   #
#                                                                              #
################################################################################

if [ "x${OSTYPE}" = "xmsys" ] ; then
  exec ${PLATFORM_DIRECTORY}/qemu.bat "$@"
  exit $?
fi

# QEMU executable and CPU model
QEMU_EXECUTABLE="/opt/QEMU/bin/qemu-system-or1k"

# debug options
if [ "x$1" = "x-debug" ] ; then
  case ${OSTYPE} in
    darwin) QEMU_SETSID= ;;
    *)      QEMU_SETSID="setsid" ;;
  esac
  QEMU_DEBUG="-S -gdb tcp:localhost:1234,ipv4"
else
  QEMU_SETSID=
  QEMU_DEBUG=
fi

# telnet port numbers and listening timeout in s
MONITORPORT=4445
SERIALPORT0=4446
SERIALPORT1=4447
TILTIMEOUT=3

# QEMU machine
${QEMU_SETSID} "${QEMU_EXECUTABLE}" \
  -M virt \
  -kernel ${KERNEL_OUTFILE} \
  -monitor "telnet:localhost:${MONITORPORT},server,nowait" \
  -chardev "socket,id=SERIALPORT0,port=${SERIALPORT0},host=localhost,ipv4=on,server=on,telnet=on,wait=on" \
  -serial "chardev:SERIALPORT0" \
  -chardev "socket,id=SERIALPORT1,port=${SERIALPORT1},host=localhost,ipv4=on,server=on,telnet=on,wait=on" \
  -serial "chardev:SERIALPORT1" \
  ${QEMU_DEBUG} \
  &
QEMU_PID=$!

# console for serial port
tcpport_is_listening ${SERIALPORT0} ${TILTIMEOUT} "*** Error"
case ${OSTYPE} in
  darwin)
    /usr/bin/osascript \
      -e "tell application \"Terminal\"" \
      -e "do script \"telnet 127.0.0.1 ${SERIALPORT0}\"" \
      -e "end tell" \
      &
    ;;
  *)
    setsid /usr/bin/xterm \
      -T "QEMU-1" -geometry 80x24 -bg blue -fg white -sl 1024 -e \
      /bin/telnet localhost ${SERIALPORT0} \
      &
    ;;
esac
# console for serial port
tcpport_is_listening ${SERIALPORT1} ${TILTIMEOUT} "*** Error"
case ${OSTYPE} in
  darwin)
    /usr/bin/osascript \
      -e "tell application \"Terminal\"" \
      -e "do script \"telnet 127.0.0.1 ${SERIALPORT1}\"" \
      -e "end tell" \
      &
    ;;
  *)
    setsid /usr/bin/xterm \
      -T "QEMU-2" -geometry 80x24 -bg blue -fg white -sl 1024 -e \
      /bin/telnet localhost ${SERIALPORT1} \
      &
    ;;
esac

# normal execution or debug execution
if [ "x$1" = "x" ] ; then
  wait ${QEMU_PID}
elif [ "x$1" = "x-debug" ] ; then
  "${GDB}" \
    -q \
    -iex "set basenames-may-differ" \
    -ex "target remote tcp:localhost:1234" \
    ${KERNEL_OUTFILE}
fi

exit $?

