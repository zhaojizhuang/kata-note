# qcow 文件生成及挂载

## qcow2 文件介绍
### QCOW2 的 COW 特性

一个 QCOW2 镜像能够用于保存其它 QCOW2 镜像(模板镜像)的变化, 这样是为了能够保证原有镜像的内容不被修改, 这就是所谓的增量镜像. 
增量镜像看着就像是一个独立的镜像文件, 其所有数据都是从模板镜像获取的. 仅当增量镜像中 clusters 的内容与模板镜像对应的 clusters 不一样时, 这些 
clusters 才会被保存到增量镜像中.

当要从增量镜像中读取一个 cluster 时, QEMU 会先检查这个 cluster 在增量镜像中有没有被分配新的数据(被改变了). 如果没有, 则会去读模板镜像中的对应位置.

### QCOW2 的快照
从原理的层面上来说, 一个增量镜像可以近似的当作一个快照, 因为增量镜像相对于模板镜像而言, 就是模板镜像的一个快照. 可以通过创建多个增量镜像来实现
创建多个模板镜像的快照, 每一个快照(增量镜像)都引用同一个模板镜像. 需要注意的是, 因为模板镜像不能够修改, 所以必须保持为 read only, 而增量镜像则为可读写. 但需要注意的是增量镜像并不是真正的 QCOW2 镜像快照, 因为「真快照」是存在于一个镜像文件里的.


## 生成 qcow 文件

```shell
qemu-img create -f raw /images/test.raw 10G
qemu-img create -f qcow2 /images/test.qcow2 10G

qemu-img info test.qcow2 
```

## 基于 backing file 创建增量镜像

如果不指定 大小的话，则和 backing file 的大小一致
```shell
qemu-img create -b test.qcow2 -f qcow2 test2.qcow2

# 重新指定大小
qemu-img create -b test.qcow2 -f qcow2 test2.qcow2 15G

qemu-img info test2.qcow2
```


## 方式一：guestmount 挂载

安装 libguestfs-tools

```shell
apt-get install libguestfs-tools
```

挂载 <device> 为 qcow2 中的设备，默认为 /dev/sda，如果不确定，可以随便指定一个
```shell
# 挂载
guestmount -a /path/to/qcow2/image -m <device> /path/to/mount/point

# 卸载
guestunmount  /path/to/mount/point
```


```shell
# 随便指定一个 deviceName 
guestmount  -a sdcard.img.qcow2 -m /dev/sdaqw qcow2_mount_point
libguestfs: error: mount_options: mount_options_stub: /dev/sdaqw: No such file or directory
guestmount: '/dev/sdaqw' could not be mounted.
guestmount: Did you mean to mount one of these filesystems?
guestmount:     /dev/sda (vfat)
```

## 方式二: qemu-nbd

```shell
# 加载  nbd max_part 表示 一个 nbd 设备支持的 partitions
modprobe nbd max_part=8
qemu-nbd --connect=/dev/nbd0 /path/to/qcow2/image

mkfs.ext4 /dev/nbd0 
mkdir -p /tmp/test-mount
mount /dev/nbd0 /tmp/test-mount
```


```shell
# 卸载
qemu-nbd -d /dev/nbd0
```