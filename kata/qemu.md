# kata 中的 qemu

kata 利用社区 qemu 5.2.0 增加了一些 patch 优化

kata-containers [QEMU patches](https://github.com/kata-containers/kata-containers/tree/main/tools/packaging/qemu)

## qemu 启动
> 取其中一个 vm 为例


```bash
/opt/kata/bin/qemu-system-x86_64 
-name sandbox-aed7737ccc2f20ca2bffd069324b86e2ec6357023a8ee1034c7f9e532cd17eae 
-uuid 977692f6-744c-4917-8ccd-ffad44020fe9 
-machine q35,accel=kvm,kernel_irqchip=on,nvdimm=on 
# 选择 主机类型，支持 pv 与 q35 ，更多类型可通过  `/opt/kata/bin/qemu-system-x86_64`  -machine help 查看
# nvdimm 是一种断电后依然可以保存数据的内存模块,用于提供虚拟机的根文件系统
#
# supported accelerators are kvm, xen, hax, hvf, whpx or tcg (default: tcg)
#                vmport=on|off|auto controls emulation of vmport (default: auto)
#                dump-guest-core=on|off include guest memory in a core dump (default=on)
#                mem-merge=on|off controls memory merge support (default: on)
#                aes-key-wrap=on|off controls support for AES key wrapping (default=on)
#                dea-key-wrap=on|off controls support for DEA key wrapping (default=on)
#                suppress-vmdesc=on|off disables self-describing migration (default=off)
#                nvdimm=on|off controls NVDIMM support (default=off)
#                memory-encryption=@var{} memory encryption object to use (default=none)
#                hmat=on|off controls ACPI HMAT support (default=off)

-cpu host,pmu=off 
# 模拟的 cpu 为 host 主机同样的型号，支持 host cpu 所有的特性
# 可通过 `cat /proc/cpuinfo` 分别在宿主机和 vm 内查看
# pmu （cpu 中的性能监控单元）Performance Monitoring Unit, PMU

-qmp unix:/run/vc/vm/aed7737ccc2f20ca2bffd069324b86e2ec6357023a8ee1034c7f9e532cd17eae/qmp.sock,server=on,wait=off 
# qemu对外提供了一个socket接口，称为qemu monitor，通过该接口，可以对虚拟机实例的整个生命周期进行管理
# ▷ 状态查看、变更
# ▷ 设备查看、变更
# ▷ 性能查看、限制
# ▷ 在线迁移
# ▷ 数据备份
# ▷ 访问内部操作系统
# 通过该socket接口传递交互的协议是qmp，全称是qemu monitor protocol，这是基于json格式的协议

-device pci-bridge,bus=pcie.0,id=pci-bridge-0,chassis_nr=1,shpc=on,addr=2 
# 添加 pci 桥

-device virtio-serial-pci,disable-modern=true,id=serial0 
# 添加 virtio pci 

-device virtconsole,chardev=charconsole0,id=console0 
-chardev socket,id=charconsole0,path=/run/vc/vm/aed7737ccc2f20ca2bffd069324b86e2ec6357023a8ee1034c7f9e532cd17eae/console.sock,server=on,wait=off 
# 添加 console 设备

-device virtio-scsi-pci,id=scsi0,disable-modern=true 
# 添加 virtio scsi

-object rng-random,id=rng0,filename=/dev/urandom 
-device virtio-rng-pci,rng=rng0 
# 挂载 virtio rng 设备

-device vhost-vsock-pci,disable-modern=true,vhostfd=3,id=vsock-2598469638,guest-cid=2598469638 
# 挂载 vsock，kata shim 和 agent 通过 vsock通信

-device vhost-user-fs-pci,chardev=char-baa1ad846772793f,tag=kataShared 
-chardev socket,id=char-baa1ad846772793f,path=/run/vc/vm/aed7737ccc2f20ca2bffd069324b86e2ec6357023a8ee1034c7f9e532cd17eae/vhost-fs.sock 
# guest kernel：作为fuse client来挂载host上导出的目录
# 添加的vhost-user-fs-pci设备用于在guest kernel和virtiofsd之间建立起vhost-user连接
# virtiofsd(同样在qemu仓库中)：host上运行的基于libfuse开发的fuse daemon，用于向guest提供fuse服务

-netdev tap,id=network-0,vhost=on,vhostfds=4,fds=5 
-device driver=virtio-net-pci,netdev=network-0,mac=2a:2b:c6:b9:b8:28,disable-modern=true,mq=on,vectors=4 
# 添加网卡，将 network ns 中的 tap 设备添加，并设置对应的 mac 地址 和 驱动

-rtc base=utc,driftfix=slew,clock=host 
# 实时时钟（rtc) 设置

-global kvm-pit.lost_tick_policy=discard 
# 设置 驱动的全局默认属性
-vga none -no-user-config 
# 显示设备
-nodefaults 
#  don't create default devices
-nographic 
# disable graphical output and redirect serial I/Os to console

--no-reboot 
# 禁用重启功能，guest执行reboot操作时，系统关闭后退出qemu-kvm，而不会再启动虚拟机

-daemonize 
# 将 qemu 的进程变为守护进程

-realtime mlock=off 
# run qemu with realtime features
# 目前支持 mlock 的设置，关闭 mlock
# mlock（memory locking）是内核实现锁定内存的一种机制，用来将进程使用的部分或全部虚拟内存锁定到物理内存。

-kernel /opt/kata/share/kata-containers/vmlinux-5.10.25-85 
# 加载的 linux 内核

-append tsc=reliable no_timer_check rcupdate.rcu_expedited=1 i8042.direct=1 i8042.dumbkbd=1 i8042.nopnp=1 i8042.noaux=1 noreplace-smp reboot=k console=hvc0 console=hvc1 cryptomgr.notests net.ifnames=0 pci=lastbus=0 root=/dev/pmem0p1 rootflags=dax,data=ordered,errors=remount-ro ro rootfstype=ext4 quiet systemd.show_status=false panic=1 nr_cpus=8 systemd.unit=kata-containers.target systemd.mask=systemd-networkd.service systemd.mask=systemd-networkd.socket scsi_mod.scan=none 
# append，此选项的作用是内核启动时，传入内核参数，可以将内核也看作为一个函数，指定内核参数

-pidfile /run/vc/vm/aed7737ccc2f20ca2bffd069324b86e2ec6357023a8ee1034c7f9e532cd17eae/pid 


-smp 1,cores=1,threads=1,sockets=8,maxcpus=8
# 初始时 1核 cpu，最大可添加到 maxcpus 8 核
# socket就是主板上插cpu的槽的数目，也就是可以插入的物理CPU的个数。
# core就是我们平时说的“核“，每个物理CPU可以双核，四核等等。
# thread就是每个core的硬件线程数，即超线程

-m 2048M,slots=10,maxmem=16811M 
# 初始时使用 2G 内存，最大可添加到 16811M 内存
# slot 表示支持的内存 插槽数

-object memory-backend-file,id=mem0,mem-path=/opt/kata/share/kata-containers/kata-clearlinux-latest.image,size=268435456,readonly=on 
-device nvdimm,id=nv0,memdev=mem0,unarmed=on 
# 添加内存 

-object memory-backend-file,id=dimm1,size=2048M,mem-path=/dev/shm,share=on 
-numa node,memdev=dimm1 
# 添加 numa 模拟


```