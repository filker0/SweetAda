#!/usr/bin/env sh

${FILEPAD} ${KERNEL_PARENT_PATH}/${KERNEL_ROMFILE} 512 || exit $?

"${PYTHON}"                                                 \
  ${KERNEL_PARENT_PATH}/${SHARE_DIRECTORY}/pc-x86-boothd.py \
  ${KERNEL_PARENT_PATH}/${KERNEL_ROMFILE}                   \
  0x2000                                                    \
  +pcboothd.dsk
#"${TCLSH}"                                                   \
#  ${KERNEL_PARENT_PATH}/${SHARE_DIRECTORY}/pc-x86-boothd.tcl \
#  ${KERNEL_PARENT_PATH}/${KERNEL_ROMFILE}                    \
#  0x2000                                                     \
#  +pcboothd.dsk

exit $?

