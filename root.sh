#!/bin/bash -eu
if [[ ${EUID} != 0 ]]; then
  echo 'Please run this script as root.' >&2
  exit 1
fi

function remount_rootfs() {
  echo '[+] Trying to remount root filesystem in read/write mode...'
  mount -o remount,rw / && return 0 || return $?
}

function remove_rootfs_verification() {
  /usr/share/vboot/bin/make_dev_ssd.sh --remove_rootfs_verification
  echo '[+] Rebooting in 3 seconds...'
  sleep 3
  reboot
}

BACKUP_PATH=/mnt/stateful_partition/arcvm_root
KERNEL_PATH=/opt/google/vms/android

if !remount_rootfs; then
  echo 'Remount failed. Did you disable rootFS verification?' >&2
  read -p -N1 'Disable rootFS verification now? (This will reboot your system) [Y/n]: ' response
  echo

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

cd /opt/google/vms/android
echo '[+] Downloading kernel...'
curl -L\# https://github.com/supechicken/ChromeOS-ARCVM-Root/raw/main/kernel.bzImage -o vmlinux.ksu

echo '[+] Backing up original kernel...'
mkdir -p ${BACKUP_PATH}
mv vmlinux ${BACKUP_PATH}/vmlinux.orig

echo "[+] Pointing ${KERNEL_PATH}/vmlinux to vmlinux.ksu..."
ln -s vmlinux.ksu ${KERNEL_PATH}/vmlinux

echo '[+] Stopping ARCVM...'
vmc stop arcvm

echo
echo "[+] All done. Original kernel stored at ${BACKUP_PATH}/vmlinux.orig"
echo '[+] You can open the KernelSU app to validate root access.'