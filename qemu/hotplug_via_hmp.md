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
device_add vhost-user-blk-pci,id=blk1,chardev=char1,addr=0x03,bus=pci-bridge-0
```

### qcow2 与 raw 文件 磁盘

1. 创建 磁盘文件
```shell
qemu-img create -f qcow2 test.qcow2 10G

qemu-img create -f raw test.raw 10G
```

2. hotplug device

```shell
# hmp
drive_add disk1  id=disk1,file=/root/zjz/disk2.qcow2,format=qcow2,if=none 
device_add virtio-blk-pci,drive=disk1,id=disk1,bus=pci-bridge-0
```

```shell
hmp
chardev-add socket,id=test-reconn,path=/run/virtiofsd-test.sock,server=off,reconnect=1
chardev-add socket,id=test-reconn,path=/run/virtiofsd-test.sock,server=off,reconnect=2,reconnect-ms=3
chardev-add socket,id=test-reconn,path=/run/virtiofsd-test.sock,server=off,reconnect-ms=4
qmp
chardev-add id=reconn-test backend={"type":"socket","data":{"addr":{"type":"unix","data":{"path":"/run/virtiofsd-test.sock"}},"server":false,"reconnect":1}}
chardev-add id=reconn-test backend={"type":"socket","data":{"addr":{"type":"unix","data":{"path":"/run/virtiofsd-test.sock"}},"server":false,"reconnect":2,"reconnect-ms":3}}
chardev-add id=reconn-test backend={"type":"socket","data":{"addr":{"type":"unix","data":{"path":"/run/virtiofsd-test.sock"}},"server":false,"reconnect-ms":4}}
```


### block device

1. hotplug device 


```shell
drive_add disk1  id=disk1,file=/dev/loop0,format=raw,if=none 
device_add virtio-blk-pci,drive=disk1,id=disk1,bus=pci-bridge-0
```


```shell
drive_add disk2  id=disk2,file=/root/kata/qemublock/a2.qcow2,format=raw,if=none 
device_add virtio-blk-pci,drive=disk2,id=disk2,bus=pci-bridge-0
```