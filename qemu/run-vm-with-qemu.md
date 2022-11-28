

## 启动 qemu


### 1. 不带 vsock 的版本 
```shell
#!/bin/bash

/opt/kata/bin/qemu-system-x86_64 \
        -name sandbox-41cb92475d2d2b8b93befe133d6df302c08482e3f4bd1eae219b46e580b673e9,debug-threads=on \
        -uuid e62392aa-df4d-4482-b269-622a8d89fc51 \
        -machine q35,accel=kvm,kernel_irqchip=on \
        -cpu host,pmu=off \
        -m 1G,slots=10,maxmem=386044M \
        -device pci-bridge,bus=pcie.0,id=pci-bridge-0,chassis_nr=1,shpc=on,addr=2,io-reserve=4k,mem-reserve=1m,pref64-reserve=1m \
        -serial mon:stdio \
        -device virtio-scsi-pci,id=scsi0,disable-modern=false \
        -object rng-random,id=rng0,filename=/dev/urandom \
        -device virtio-rng-pci,rng=rng0 \
        -rtc base=utc,driftfix=slew,clock=host \
        -global kvm-pit.lost_tick_policy=discard \
        -vga none \
        -no-user-config \
        -nodefaults \
        -nographic \
        --no-reboot \
        -object memory-backend-memfd,id=dimm0,size=1G,hugetlb=on,hugetlbsize=2M \
        -numa node,memdev=dimm0 \
        -kernel /opt/kata/share/kata-containers/vmlinux.container \
        -device virtio-blk-pci,disable-modern=false,drive=image-f15d6c054f7f189c,scsi=off,config-wce=off,share-rw=on,serial=image-f15d6c054f7f189c \
        -drive id=image-f15d6c054f7f189c,file=/opt/kata/share/kata-containers/kata-containers.img,aio=threads,format=raw,if=none,readonly=on \
        -append "root=/dev/vda1 ro console=ttyS0" \
        -smp 64 \
        -qmp unix:/tmp/qmp.sock,server=on,wait=off \
        -device pcie-root-port,port=0x10,chassis=1,id=pci.1,bus=pcie.0,multifunction=on,addr=0xf \
        -device pcie-root-port,port=0x11,chassis=2,id=pci.2,bus=pcie.0,addr=0xf.0x1 \
        -device virtio-net-pci,netdev=network-0,mac=9a:e8:e9:ea:eb:ec,id=net1,vectors=9,mq=on \
        -netdev tap,id=network-0,ifname=tap0,vhost=on,script=no,downscript=no
```


### 2. 带有 vsock 的版本

```shell
/opt/kata/bin/qemu-system-x86_64 \
        -name sandbox-41cb92475d2d2b8b93befe133d6df302c08482e3f4bd1eae219b46e580b673e9,debug-threads=on \
        -uuid e62392aa-df4d-4482-b269-622a8d89fc51 \
        -machine q35,accel=kvm,kernel_irqchip=on \
        -cpu host,pmu=off \
        -m 1G,slots=10,maxmem=386044M \
        -device pci-bridge,bus=pcie.0,id=pci-bridge-0,chassis_nr=1,shpc=off,addr=2,io-reserve=4k,mem-reserve=1m,pref64-reserve=1m \
        -serial mon:stdio \
        -device virtio-scsi-pci,id=scsi0,disable-modern=false \
        -object rng-random,id=rng0,filename=/dev/urandom \
        -device virtio-rng-pci,rng=rng0 \
        -rtc base=utc,driftfix=slew,clock=host \
        -global kvm-pit.lost_tick_policy=discard \
        -vga none \
        -no-user-config \
        -nodefaults \
        -nographic \
        --no-reboot \
        -object memory-backend-memfd,id=dimm0,size=1G,hugetlb=on,hugetlbsize=2M \
        -numa node,memdev=dimm0 \
        -kernel /opt/kata/share/kata-containers/vmlinux.container \
        -device vhost-vsock-pci,disable-modern=true,id=vsock-123456789,guest-cid=123456789 \
        -device virtio-blk-pci,disable-modern=false,drive=image-f15d6c054f7f189c,scsi=off,config-wce=off,share-rw=on,serial=image-f15d6c054f7f189c \
        -drive id=image-f15d6c054f7f189c,file=/opt/kata/share/kata-containers/kata-containers.img,aio=threads,format=raw,if=none,readonly=on \
         -append "root=/dev/vda1 ro console=ttyS0 systemd.show_status=false panic=1 nr_cpus=4 systemd.unit=kata-containers.target systemd.mask=systemd-networkd.service systemd.mask=systemd-networkd.socket scsi_mod.scan=none agent.log=debug agent.debug_console agent.debug_console_vport=1026 agent.log=debug" \
        -smp 64 \
        -monitor unix:/tmp/qmp.sock,server=on,wait=off \
        -device pcie-root-port,port=0x10,chassis=1,id=pci.1,bus=pcie.0,multifunction=on,addr=0xf \
        -device pcie-root-port,port=0x11,chassis=2,id=pci.2,bus=pcie.0,addr=0xf.0x1 \
        -device virtio-net-pci,netdev=network-0,mac=9a:e8:e9:ea:eb:ec,id=net1,vectors=9,mq=on \
        -netdev tap,id=network-0,ifname=tap0,vhost=on,script=no,downscript=no
```


## 进入 vm
### 通过 vsock 进入

通过 vsock 进入 vm 需要借助 kata-runtime, kata-runtime 需要修改下

```go
// src/runtime/cmd/kata-runtime/kata-exec.go
func getConn(sandboxID string, port uint64) (net.Conn, error) {
	
	//client, err := kataMonitor.BuildShimClient(sandboxID, defaultTimeout)
	//if err != nil {
	//	return nil, err
	//}
	//
	//resp, err := client.Get("http://shim/agent-url")
	//if err != nil {
	//	return nil, err
	//}
	//
	//if resp.StatusCode != http.StatusOK {
	//	return nil, fmt.Errorf("Failure from %s shim-monitor: %d", sandboxID, resp.StatusCode)
	//}
	//
	//defer resp.Body.Close()
	//data, err := ioutil.ReadAll(resp.Body)
	//if err != nil {
	//	return nil, err
	//}
	//
	//sock := strings.TrimSuffix(string(data), "\n")
	sock := "vsock://123456789:1026"

}
```
编译 kata-runtime
```shell
cd src/runtime
make runtime
cp ./kata-runtime /usr/local/bin/kata-runtime-debug

```

进入 vm

```shell
kata-runtime-debug exec aaa
```

### hmp 连接

qemu 启动时 -monitor 是 hmp 方式，-qmp 是 qmp 方式
hmp 方式 更人性化一点

#### 方式一：

```shell
nc -U /tmp/qmp.sock

```

#### 方式二

```shell
# 或者 
socat - unix:/tmp/qmp.sock
```


#### hotplugin vhostuser blk 设备

```shell
chardev-add socket,id=char1,path=/var/run/kata-containers/vhost-user/block/sockets/vhostblk0,wait=off
chardev-add socket,id=char2,path=/var/tmp/spdk.sock
chardev-add socket,id=blk4,path=/var/run/byted-spdk/vm-75p4/disk.sock 

chardev-add socket,id=blk2,path=/var/run/kata-containers/vhost-user/block/sockets/blk2


# return ok

device_add vhost-user-blk-pci,id=blk2,chardev=blk2,addr=0x02,bus=pci-bridge-0

device_add vhost-user-blk-pci,id=virtio-blk0,chardev=blk3,addr=02,bus=pci-bridge-0
# return ok

```


参考  https://blog.csdn.net/wujianyongw4/article/details/123595318