# Zarf Airgap Installation (WIP)

Prerequisites (for macos)

```shell
git clone https://github.com/defenseunicorns/zarf
cp zarf.yaml zarf
cd zarf
zarf package create -o build -a amd64 --confirm
zarf init build/zarf-init-amd64-v0.22.2.tar.zst
cd big-bang-core
zarf package create 
```

