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

function remount_rootfs() {
  echo '[+] Trying to remount root filesystem in read/write mode...'
  mount -o remount,rw / && return 0 || return $?
}

function remove_rootfs_verification() {
  /usr/share/vboot/bin/make_dev_ssd.sh --remove_rootfs_verification --partitions 3
  /usr/share/vboot/bin/make_dev_ssd.sh --remove_rootfs_verification --partitions 5
  echo -e "${YELLOW}Please run this script again after reboot.${RESET}"
  echo '[+] Rebooting in 3 seconds...'
  sleep 3
  reboot
}

if [[ ${EUID} != 0 ]]; then
  echo -e "${RED}Please run this script as root.${RESET}" >&2
  exit 1
fi

if [ -L ${KERNEL_PATH}/vmlinux ]; then
  echo -e "${RED}Your device is already rooted.${RESET}"
  exit 1
fi

if ! remount_rootfs; then
  echo -e "${YELLOW}Remount failed. Did you disable rootFS verification?${RESET}" >&2
  read -N1 -p 'Disable rootFS verification now? (This will reboot your system) [Y/n]: ' response < /dev/tty
  echo -e "\n"

  case $response in
  Y|y)
    remove_rootfs_verification
  ;;
  *)
    echo 'No changes made.'
    exit 1
  ;;
  esac
fi

cd /tmp
echo '[+] Downloading kernel...'
curl -L\# https://github.com/tiann/KernelSU/releases/download/v0.6.6/kernel-ARCVM-x86_64-5.10.178.zip -o ksu.zip

echo '[+] Decompressing kernel...'
mkdir -p ksu
mount-zip ksu.zip ksu

cd ${KERNEL_PATH}

echo '[+] Backing up original kernel...'
mkdir -p ${BACKUP_PATH}
mv vmlinux vmlinux.orig
cp /tmp/ksu/bzImage ${BACKUP_PATH}/vmlinux.ksu

echo "[+] Pointing ${KERNEL_PATH}/vmlinux to vmlinux.ksu..."
ln -s vmlinux.ksu ${KERNEL_PATH}/vmlinux

echo "[+] Cleanup..."
fuser-mount -u /tmp/ksu
rmdir /tmp/ksu

echo
echo -e "${GREEN}[+] All done. Please reboot to apply changes."
echo -e "${GREEN}[+] You can open the KernelSU app to validate root access after reboot.${RESET}"
echo

read -N1 -p 'Reboot now? [Y/n]: ' response < /dev/tty
echo -e "\n"

case $response in
Y|y)
  echo 'Rebooting...'
  reboot
  sleep 10
;;
esac
