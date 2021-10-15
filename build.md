# 编译 kata-containers 组件

## 1. 编译环境准备

### 1. golang 开发环境配置

下载 golang 压缩包
```bash
wget https://dl.google.com/go/go1.16.3.linux-amd64.tar.gz
```
配置环境变量

```bash
mkdir /root/go
echo "export GOROOT=/usr/local/go" >> /etc/profile
echo "export GOPATH=/root/go" >> /etc/profile
echo "export GO111MODULE=on" >> /etc/profile
echo "export PATH=$PATH:$GOPATH/bin" >> /etc/profile
source /etc/profile
```
### 2. rust 开发环境配置

安装
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# 根据提示选择默认配置：1
```

配置环境变量 
```bash
source $HOME/.cargo/env
```

创建config文件，配置rust加速源
```bash
[~]# cat $HOME/.cargo/config
[source.crates-io]
registry = "https://github.com/rust-lang/crates.io-index"
replace-with = 'ustc'
[source.ustc]
registry = "git://mirrors.ustc.edu.cn/crates.io-index"
```


** rust 安装依赖(重要)**
安装依赖 `x86_64-unknown-linux-musl` ，不然后续编译 agent 时会失败

```bash
rustup target add x86_64-unknown-linux-musl
```
## 2. kata-containers 代码下载

```bash
mkdir -p $GOPATH/src/github.com/kata-containers
cd $GOPATH/src/github.com/kata-containers/kata-containers

git clone git@github.com:kata-containers/kata-containers.git
```

## 3. 整体编译

在 kata-containers 顶层目录下 执行 

```bash
make build-all
```

## 4. 单独编译

### 1. 编译 kata-runtime 相关二进制可执行文件

此步骤会编译
- 二进制可执行文件
  - kata-runtime
  - containerd-shim-kata-v2
  - kata-monitor
  - kata-netmon
- configuration.toml 文件


```bash
cd $GOPATH/src/github.com/kata-containers/kata-containers/src/runtime
make
```

### 2. 编译 kata-agent

```bash
cd $GOPATH/src/github.com/kata-containers/kata-containers/src/agent
make 

```

### 3. 编译 rootfs

```bash

export distro=clearlinux # 可选项 alpine, centos, clearlinux, debian, euleros, fedora, suse,  ubuntu
export ROOTFS_DIR=${GOPATH}/src/github.com/kata-containers/kata-containers/tools/osbuilder/rootfs-builder/rootfs
sudo rm -rf ${ROOTFS_DIR}
cd $GOPATH/src/github.com/kata-containers/kata-containers/tools/osbuilder/rootfs-builder
script -fec 'sudo -E GOPATH=$GOPATH USE_DOCKER=true SECCOMP=no ./rootfs.sh ${distro}'

# 如果要编译带有 console 的镜像则执行如下命令
# script -fec 'USE_DOCKER=true EXTRA_PKGS="bash coreutils" ./rootfs.sh centos'
```

### 4. 编译 rootfs 镜像

```bash
cd $GOPATH/src/github.com/kata-containers/kata-containers/tools/osbuilder/image-builder
script -fec 'sudo -E USE_DOCKER=true ./image_builder.sh ${ROOTFS_DIR}'
```

## 调试 agent

`kata-agent` 编译时间在 2 min 左右，加上制作 rootfs，编译 rootfs 镜像，一套流程下来要 20多分钟。
调试时可以通过 mount kata-containers.img 替换其中的  `kata-agent` 二进制, 秒级完成，节省宝贵的时间

```bash
#!/usr/bin/bash

agent="$GOPATH/src/github.com/kata-containers/kata-containers/src/agent/target/x86_64-unknown-linux-musl/release/kata-agent"
img="$(realpath /data00/kata/share/kata-containers/kata-containers.img)"

dev="$(sudo losetup --show -f -P "$img")"
echo "$dev"

part="${dev}p1"

sudo mount $part /mnt

sudo install -b $agent /mnt/usr/bin/kata-agent

sudo umount /mnt

sudo losetup -d "$dev"
```


## 参考

- https://github.com/kata-containers/kata-containers/blob/main/docs/Developer-Guide.md
- https://blog.csdn.net/u010827484/article/details/117488293