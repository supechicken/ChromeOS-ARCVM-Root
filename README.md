## Scripts for rooting ChromeOS ARCVM-based Android subsystem (Android 11+)
Root ChromeOS Android subsystem with KernelSU, only support ARCVM (not ARC++)

All kernel bzImage under this directory are extracted from KernelSU's official ARCVM CI workflow

Available kernels are under `kernel/` directory

### Instruction
#### Root
```shell
curl -Ls https://raw.githubusercontent.com/supechicken/ChromeOS-ARCVM-Root/main/root.sh | sudo bash -eu
```

#### Unroot
```shell
curl -Ls https://raw.githubusercontent.com/supechicken/ChromeOS-ARCVM-Root/main/unroot.sh | sudo bash -eu
```
