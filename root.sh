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

KSU_VER='v1.0.5'
KERNEL_VER='5.10.230'
ARCH="$(arch)"

# prevent conflict between system libraries and Chromebrew libraries
unset LD_LIBRARY_PATH
export PATH=/bin:/sbin:/usr/bin:/usr/sbin

function remount_rootfs() {
  echo '[+] Trying to remount root filesystem in read/write mode...'
  mount -o remount,rw / && return 0 || return $?
}

function remove_rootfs_verification() {
  # KERN-A B for arm  ROOT-A B for x64
  if [[ "$ARCH" =~ "arm64" ]];then
    /usr/share/vboot/bin/make_dev_ssd.sh --remove_rootfs_verification --partitions 2
    /usr/share/vboot/bin/make_dev_ssd.sh --remove_rootfs_verification --partitions 4
  else
    /usr/share/vboot/bin/make_dev_ssd.sh --remove_rootfs_verification --partitions 3
    /usr/share/vboot/bin/make_dev_ssd.sh --remove_rootfs_verification --partitions 5
  fi
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
echo "${KSU_VER}/kernel-ARCVM-${ARCH}-${KERNEL_VER}.zip"
curl -L -'#' "https://github.com/tiann/KernelSU/releases/download/${KSU_VER}/kernel-ARCVM-${ARCH}-${KERNEL_VER}.zip" -o ksu.zip

echo '[+] Decompressing kernel...'
mkdir -p ksu
mount-zip ksu.zip ksu
cp ksu/*Image ${KERNEL_PATH}/vmlinux.ksu

cd ${KERNEL_PATH}

echo '[+] Backing up original kernel...'
mkdir -p ${BACKUP_PATH}
mv vmlinux vmlinux.orig
cp vmlinux.orig ${BACKUP_PATH}/vmlinux.orig

echo "[+] Pointing ${KERNEL_PATH}/vmlinux to vmlinux.ksu..."
ln -s vmlinux.ksu ${KERNEL_PATH}/vmlinux

echo "[+] Cleanup..."
fusermount -u /tmp/ksu
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
