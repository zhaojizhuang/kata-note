

## 手动启动 qemu
```shell
#!/bin/bash

/opt/kata/bin/qemu-system-x86_64 \
        -name sandbox-41cb92475d2d2b8b93befe133d6df302c08482e3f4bd1eae219b46e580b673e9,debug-threads=on \
        -uuid e62392aa-df4d-4482-b269-622a8d89fc51 \
        -machine q35,accel=kvm,kernel_irqchip=on \
        -cpu host,pmu=off \
        -m 2G,slots=10,maxmem=386044M \
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
        -object memory-backend-memfd,id=dimm0,size=2G,hugetlb=on,hugetlbsize=2M \
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

