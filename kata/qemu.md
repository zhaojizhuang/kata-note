# kata 集成 qemu

kata 利用社区 qemu 5.2.0 增加了一些 patch 优化

kata-containers [QEMU patches](https://github.com/kata-containers/kata-containers/tree/main/tools/packaging/qemu)

## qemu 启动
> 取其中一个 vm 为例


```bash
/opt/kata/bin/qemu-system-x86_64 
-name sandbox-aed7737ccc2f20ca2bffd069324b86e2ec6357023a8ee1034c7f9e532cd17eae 
-uuid 977692f6-744c-4917-8ccd-ffad44020fe9 
-machine q35,accel=kvm,kernel_irqchip=on,nvdimm=on 
-cpu host,pmu=off 
-qmp unix:/run/vc/vm/aed7737ccc2f20ca2bffd069324b86e2ec6357023a8ee1034c7f9e532cd17eae/qmp.sock,server=on,wait=off 
-m 2048M,slots=10,maxmem=16811M 
-device pci-bridge,bus=pcie.0,id=pci-bridge-0,chassis_nr=1,shpc=on,addr=2 
-device virtio-serial-pci,disable-modern=true,id=serial0 -device virtconsole,chardev=charconsole0,id=console0 
-chardev socket,id=charconsole0,path=/run/vc/vm/aed7737ccc2f20ca2bffd069324b86e2ec6357023a8ee1034c7f9e532cd17eae/console.sock,server=on,wait=off 
-device nvdimm,id=nv0,memdev=mem0,unarmed=on 
-object memory-backend-file,id=mem0,mem-path=/opt/kata/share/kata-containers/kata-clearlinux-latest.image,size=268435456,readonly=on 
-device virtio-scsi-pci,id=scsi0,disable-modern=true 
-object rng-random,id=rng0,filename=/dev/urandom 
-device virtio-rng-pci,rng=rng0 
-device vhost-vsock-pci,disable-modern=true,vhostfd=3,id=vsock-2598469638,guest-cid=2598469638 
-chardev socket,id=char-baa1ad846772793f,path=/run/vc/vm/aed7737ccc2f20ca2bffd069324b86e2ec6357023a8ee1034c7f9e532cd17eae/vhost-fs.sock 
-device vhost-user-fs-pci,chardev=char-baa1ad846772793f,tag=kataShared 
-netdev tap,id=network-0,vhost=on,vhostfds=4,fds=5 
-device driver=virtio-net-pci,netdev=network-0,mac=2a:2b:c6:b9:b8:28,disable-modern=true,mq=on,vectors=4 
-rtc base=utc,driftfix=slew,clock=host 
-global kvm-pit.lost_tick_policy=discard 
-vga none -no-user-config 
-nodefaults 
-nographic 
--no-reboot 
-daemonize 
-object memory-backend-file,id=dimm1,size=2048M,mem-path=/dev/shm,share=on 
-numa node,memdev=dimm1 
-realtime mlock=off 
-kernel /opt/kata/share/kata-containers/vmlinux-5.10.25-85 
-append tsc=reliable no_timer_check rcupdate.rcu_expedited=1 i8042.direct=1 i8042.dumbkbd=1 i8042.nopnp=1 i8042.noaux=1 noreplace-smp reboot=k console=hvc0 console=hvc1 cryptomgr.notests net.ifnames=0 pci=lastbus=0 root=/dev/pmem0p1 rootflags=dax,data=ordered,errors=remount-ro ro rootfstype=ext4 quiet systemd.show_status=false panic=1 nr_cpus=8 systemd.unit=kata-containers.target systemd.mask=systemd-networkd.service systemd.mask=systemd-networkd.socket scsi_mod.scan=none 
-pidfile /run/vc/vm/aed7737ccc2f20ca2bffd069324b86e2ec6357023a8ee1034c7f9e532cd17eae/pid 
-smp 1,cores=1,threads=1,sockets=8,maxcpus=8
```