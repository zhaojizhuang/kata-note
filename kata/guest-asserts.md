# 轻量虚拟化相关组件 (Guest assets)

包含精简后的 Guest kernel  和 Guest image 

在 `/opt/kata/share/defaults/kata-containers` 下可以看到相关的配置，
因为 kata 支持多种 hypervisor，可以看到该文件夹下包含多个配置文件，其中 `configuration.toml` 是默认的配置，
通过软连接指向配置文件

```bash
configuration-acrn.toml
configuration-clh.toml
configuration-fc.toml
configuration-qemu.toml
configuration.toml -> configuration-qemu.toml
```

默认的 hypervisor 是 qemu

```bash
[hypervisor.qemu]
path = "/opt/kata/bin/qemu-system-x86_64"
kernel = "/opt/kata/share/kata-containers/vmlinux.container"
image = "/opt/kata/share/kata-containers/kata-containers.img"
machine_type = "q35"
```

## Guest kernel

安全容器实例所用的内核，也就是 `/opt/kata/share/kata-containers/vmlinux.container`， 这是一个由 kata 精简后的 linux 内核，
对内核启动时间和最小内存占用进行了高度优化，仅提供容器工作负载所需的服务。

**kata 2.2.0 版本默认的 linux 内核版本为 5.10.25**

## Guest Image

Kata 支持 `initrd` 和 `rootfs` 两种类型的系统镜像

### 1. initrd 类型

initrd (initialized ramdisk)是用一部分内存模拟成磁盘，让操作系统访问

initrd.img 是一个小的系统镜像，包含一个最小的 linux 系统,采用 `cpio(1)` 格式压缩；启动过程中
解压缩到 tmpfs 中，成为初始的根文件系统


### 2. rootfs 类型



参考 
1. [关于Linux内核vmlinuz、initrd.img和System.map](https://blog.csdn.net/Geek_Tank/article/details/69479196)