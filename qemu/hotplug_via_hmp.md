# 通过  hmp 连接 qemu 虚拟机

qemu 启动时添加 monitor socket

```shell
qemu ....
 -monitor unix:/tmp/qmp.sock,server=on,wait=off 
```


## 连接 hmp

```shell
socat - unix:/tmp/qmp.sock
```

## hotplug device

### vhost user device

```shell
chardev-add socket,id=char1,path=/var/tmp/spdk.sock
device_add vhost-user-blk-pci,id=blk1,chardev=char1,addr=0x03,bus=pci-bridge-0,num-queues=32
```

### qcow2 与 raw 文件 磁盘

1. 创建 磁盘文件
```shell
qemu-img create -f qcow2 test.qcow2 10G

qemu-img create -f raw test.raw 10G
```

2. hotplug device

```shell
drive_add disk1  id=disk1,file=/root/zjz/disk2.qcow2,format=qcow2,if=none 
device_add virtio-blk-pci,drive=disk1,id=disk1,bus=pci-bridge-0
```
