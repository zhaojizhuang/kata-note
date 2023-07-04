# block device with throttle

参考 https://github.com/qemu/qemu/blob/master/docs/throttle.txt

## hotplug with throttle
```shell
drive_add disk2  id=disk2,file=/root/kata/qemublock/a2.raw,format=raw,if=none
device_add virtio-blk-pci,drive=disk2,id=disk2,bus=pci-bridge-0

block_set_io_throttle disk2/virtio-backend 1048576000 0 0 5000 0 0
```



## test

```shell
# install iostat
apt-get install sysstat

```