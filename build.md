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

#### agent 的 rpc protocols 编译
用于在 Goland IDE 中查看引用关系

rust 语言
```shell
cd $GOPATH/src/github.com/kata-containers/kata-containers/src/libs/protocols
cargo clean
cargo build

# 结果生成在 $GOPATH/src/github.com/kata-containers/kata-containers/src/libs/protocols/src
```
go 语言
```shell
cd $GOPATH/src/github.com/kata-containers/kata-containers/src/agent
make generate-protocols
```


```bash
cd $GOPATH/src/github.com/kata-containers/kata-containers/src/agent
make 

```

### 3. 编译 rootfs

```bash

export distro=centos # 可选项 alpine, centos, clearlinux, debian, euleros, fedora, suse,  ubuntu
export ROOTFS_DIR=${GOPATH}/src/github.com/kata-containers/kata-containers/tools/osbuilder/rootfs-builder/rootfs
sudo rm -rf ${ROOTFS_DIR}
cd $GOPATH/src/github.com/kata-containers/kata-containers/tools/osbuilder/rootfs-builder
script -fec 'sudo -E USE_DOCKER=true SECCOMP=no EXTRA_PKGS="bash coreutils" ./rootfs.sh ${distro}'

# EXTRA_PKGS 为需要打包到rootfs 中的二进制， coreutils 为 包含 bash，kata exec 进入 console 用的
# 最新版本已经默认加了 coreustils 了
```

### 4. 编译 rootfs 镜像

```bash
cd $GOPATH/src/github.com/kata-containers/kata-containers/tools/osbuilder/image-builder
script -fec 'sudo -E USE_DOCKER=true ./image_builder.sh ${ROOTFS_DIR}'
```


### 5. 通过 make 构建

```bash
# 部分 rootfs 构建时需要下载对应的安装包，需要代理
# export  http_proxy=xxx https_proxy= xxx
cd $GOPATH/src/github.com/kata-containers/kata-containers/tools/osbuilder/
make clean # 清除上次构建结果
make DISTRO=ubuntu \
 OS_VERSION=10.10 \
 EXTRA_PKGS="chrony xfsprogs strace lsof nfs-common binutils ipvsadm ethtool e2fsprogs netcat tcpdump iproute2 net-tools telnet iputils-ping" \
 USE_DOCKER=true image
```

## 参考

- https://github.com/kata-containers/kata-containers/blob/main/docs/Developer-Guide.md
- https://blog.csdn.net/u010827484/article/details/117488293