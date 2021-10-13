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
cd $GOPATH/src
git clone git@github.com:kata-containers/kata-containers.git
```

## 3. 整体编译

在 kata-containers 顶层目录下 执行 

```bash
make build-all
```

## 4. 单独编译


## 参考

https://blog.csdn.net/u010827484/article/details/117488293