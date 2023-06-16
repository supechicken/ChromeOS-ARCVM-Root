#!/bin/bash
set -eu

RED='\e[1;31m'
YELLOW='\e[1;33m'
GREEN='\e[1;32m'
BLUE='\e[1;34m'
GRAY='\e[0;37m'
MAGENTA='\e[1;35m'
RESET='\e[0m'

BACKUP_PATH=/mnt/stateful_partition/arcvm_root
KERNEL_PATH=/opt/google/vms/android
unset LD_LIBRARY_PATH

if [ ! -L ${KERNEL_PATH}/vmlinux ]; then
  echo -e "${RED}Your device not rooted.${RESET}"
  exit 1
fi

read -p -N1 'Are you sure to remove root? [Y/n]: ' response
echo

case $response in
Y|y);;
*)
  echo 'No changes made.'
  exit 1
;;
esac

cd ${KERNEL_PATH}
echo "[+] Restoring ${KERNEL_PATH}"
rm vmlinux*

echo "[+] Replacing ${KERNEL_PATH}/vmlinux with stock kernel..."
cp ${BACKUP_PATH}/vmlinux.orig ${KERNEL_PATH}/vmlinux

echo '[+] Stopping ARCVM...'
vmc stop arcvm

echo "[+] All Done"