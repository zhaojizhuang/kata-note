# kata 使用 spdk 

## 编译安装 spdk

参考 SPDK [getting started guide](https://spdk.io/doc/getting_started.html).


### 编译

```shell
# 1. 下载源码
git clone https://github.com/spdk/spdk --recursive

# 2. 下载依赖
cd spdk
scripts/pkgdep.sh

# 3. 构建
./configure
make
```


> 如果开发机内存不足，清理 内存 cache,可执行下面脚本 `sync; echo 1 > /proc/sys/vm/drop_caches`


### 运行 spdk

```shell
# 只需要执行一次，如果是重置，使用  scripts/setup.sh reset
sudo HUGEMEM=4096 PCI_WHITELIST="none" scripts/setup.sh
sudo mkdir -p /var/run/kata-containers/vhost-user/block/sockets/
sudo mkdir -p /var/run/kata-containers/vhost-user/block/devices/
sudo mkdir -p /run/kata-containers/shared/direct-volumes/
sudo <spdk_src_root>/build/bin/spdk_tgt -S /var/run/kata-containers/vhost-user/block/sockets/ &
```