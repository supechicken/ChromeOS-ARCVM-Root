## Scripts for rooting ChromeOS ARCVM-based Android subsystem (Android 11+)
Root ChromeOS Android subsystem with KernelSU, only support ARCVM (not ARC++)

This script will download and install the prebuilt ARCVM kernel (v0.6.6) from KernelSU GitHub Releases.

### Instruction
**Note: This script will NOT install the KernelSU Android app automatically, you need to install it yourself**

#### Root
```shell
curl -Ls https://raw.githubusercontent.com/supechicken/ChromeOS-ARCVM-Root/main/root.sh | sudo bash -eu
```

#### Unroot
```shell
curl -Ls https://raw.githubusercontent.com/supechicken/ChromeOS-ARCVM-Root/main/unroot.sh | sudo bash -eu
```

### Notes
- Try installing the KernelSU module under `root_fix_module/` if root does not work on some of your Android apps.