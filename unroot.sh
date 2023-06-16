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

# prevent conflict between system libraries and Chromebrew libraries
unset LD_LIBRARY_PATH
export PATH=/bin:/sbin:/usr/bin:/usr/sbin

if [[ ${EUID} != 0 ]]; then
  echo -e "${RED}Please run this script as root.${RESET}" >&2
  exit 1
fi

if [ ! -L ${KERNEL_PATH}/vmlinux ]; then
  echo -e "${RED}Your device did not rooted.${RESET}"
  exit 1
fi

read -N1 -p 'Are you sure to remove root? [Y/n]: ' response < /dev/tty
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
cp ${BACKUP_PATH}/vmlinux.orig vmlinux

echo
echo -e "${GREEN}[+] All Done. Please reboot to apply changes.${RESET}"
echo

read -N1 -p 'Reboot now? [Y/n]: ' response < /dev/tty
echo

case $response in
Y|y)
  echo 'Rebooting...
  reboot
;;
esac