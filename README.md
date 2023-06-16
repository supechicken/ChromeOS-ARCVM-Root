## Scripts for rooting ChromeOS ARCVM-based Android subsystem (Android 11+)
Root ChromeOS Android subsystem with KernelSU, only support ARCVM (not ARC++)

The kernel bzImage (version 5.10.178) on this repository is extracted from [KernelSU's official ARCVM CI workflow](https://github.com/tiann/KernelSU/actions/runs/5290135303)

### Instruction
#### Root
```shell
curl -Ls https://raw.githubusercontent.com/supechicken/ChromeOS-ARCVM-Root/main/root.sh | sudo bash -eu
```

#### Unroot
```shell
curl -Ls https://raw.githubusercontent.com/supechicken/ChromeOS-ARCVM-Root/main/unroot.sh | sudo bash -eu
```
