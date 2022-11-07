
/opt/kata/bin/qemu-system-x86_64 \
    -name sandbox-bba72083f2721660fed10b87a9f7aa9b33a7a4d4d00ed2877e15b1a330433e85 \
    -uuid 77c801a2-6e21-40e3-a2dd-ed0a062750f7 \
    -machine q35,accel=kvm,kernel_irqchip=on \
    -cpu host,pmu=off \
    -qmp unix:/run/vc/vm/qmp.sock,server=on,wait=off \
    -m 2048M,slots=10,maxmem=16392M \
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
    -device vhost-vsock-pci,disable-modern=true,id=vsock-123456789,guest-cid=123456789 \
    -object memory-backend-file,id=dimm1,size=2048M,mem-path=/dev/shm,share=on \
    -numa node,memdev=dimm1 \
    -kernel /opt/kata/share/kata-containers/vmlinux-5.19.2-96 \
    -append " 1-b 1rd.emergency console=ttyS0 tsc=reliable no_timer_check rcupdate.rcu_expedited=1 i8042.direct=1 i8042.dumbkbd=1 i8042.nopnp=1 i8042.noaux=1 noreplace-smp reboot=k console=hvc0 console=hvc1 cryptomgr.notests net.ifnames=0 pci=lastbus=0 debug panic=1 nr_cpus=6 scsi_mod.scan=none agent.log=debug agent.debug_console agent.debug_console_vport=1026 agent.log=debug" \
    -smp 1,cores=1,threads=1,sockets=6,maxcpus=6

    -initrd /data00/workspace/pm_initrd/kata-containers-initrd-5.4.56.bsk.10-amd64.img \
exit 0

/opt/kata/libexec/kata-qemu/virtiofsd  -o cache=auto -o no_posix_lock -o source=/run/kata-containers/shared/sandboxes/test_virtiofs/shared -d --thread-pool-size=1     --socket-path=/run/vc/vm/test_virtiofs/vhost-fs.sock


    -device vhost-vsock-pci,disable-modern=true,id=vsock-123456789,guest-cid=123456789 \
    -device vhost-vsock-pci,disable-modern=true,vhostfd=3,id=vsock-123456789,guest-cid=123456789 \

    -chardev socket,id=char-test_virtiofs,path=/run/vc/vm/test_virtiofs/vhost-fs.sock \
    -device vhost-user-fs-pci,chardev=char-test_virtiofs,tag=kataShared,queue-size=1024 \

    -serial "null" \
    -serial mon:stdio \
    -device virtio-serial-pci,disable-modern=true,id=serial0  -device "virtconsole,chardev=charconsole0,id=console0"  -chardev "stdio,id=charconsole0" \

    -chardev "stdio,id=charconsole0" \
    -chardev file,id=charconsole0,path=/run/vc/vm/console.log,server=on,wait=off \
    -chardev socket,id=charconsole0,path=/run/vc/vm/console.sock,server=on,wait=off \

    -device vhost-vsock-pci,disable-modern=true,vhostfd=3,id=vsock-1457355982,guest-cid=1457355982 \
    -device virtio-serial-pci,disable-modern=true,id=serial0 \
    -device virtconsole,chardev=charconsole0,id=console0 \
    -chardev socket,id=charconsole0,path=/run/vc/vm/bba72083f2721660fed10b87a9f7aa9b33a7a4d4d00ed2877e15b1a330433e85/console.sock,server=on,wait=off \
    -device virtio-scsi-pci,id=scsi0,disable-modern=true \


    -chardev socket,id=char-e4d6cc36ff9f105f,path=/run/vc/vm/bba72083f2721660fed10b87a9f7aa9b33a7a4d4d00ed2877e15b1a330433e85/vhost-fs.sock \
    -device vhost-user-fs-pci,chardev=char-e4d6cc36ff9f105f,tag=kataShared \
    -netdev tap,id=network-0,vhost=on,vhostfds=4,fds=5 \
    -device driver=virtio-net-pci,netdev=network-0,mac=82:da:7d:cd:4a:0f,disable-modern=true,mq=on,vectors=4 \


    -daemonize \


    -pidfile /run/vc/vm/bba72083f2721660fed10b87a9f7aa9b33a7a4d4d00ed2877e15b1a330433e85/pid \
    -D /run/vc/vm/bba72083f2721660fed10b87a9f7aa9b33a7a4d4d00ed2877e15b1a330433e85/qemu.log \


    -initrd /data00/workspace/kata_build/kata-containers/tools/osbuilder/initrd-builder/kata-containers-initrd.img \
    -initrd /data00/workspace/pm_initrd/kata-containers-initrd-5.4.56.bsk.10-amd64.img \
    -initrd /data00/workspace/kata_build/kata-containers/tools/osbuilder/initrd-builder/kata-containers-initrd.img.systemd_init \
    -kernel /data00/workspace/pm_initrd/vmlinuz-5.4.56.bsk.10-amd64 \
    -kernel /data00/kata/share/kata-containers/vmlinux-5.10.25-88 \

    -append " console=ttyS0 rdinit=/bin/sh tsc=reliable no_timer_check rcupdate.rcu_expedited=1 i8042.direct=1 i8042.dumbkbd=1 i8042.nopnp=1 i8042.noaux=1 noreplace-smp reboot=k console=hvc0 console=hvc1 cryptomgr.notests net.ifnames=0 pci=lastbus=0 debug panic=1 nr_cpus=6 scsi_mod.scan=none agent.log=debug agent.debug_console agent.debug_console_vport=1026 agent.log=debug" \
    -append "-b rd.emergency console=ttyS0 tsc=reliable no_timer_check rcupdate.rcu_expedited=1 i8042.direct=1 i8042.dumbkbd=1 i8042.nopnp=1 i8042.noaux=1 noreplace-smp reboot=k console=hvc0 console=hvc1 cryptomgr.notests net.ifnames=0 pci=lastbus=0 debug panic=1 nr_cpus=6 scsi_mod.scan=none agent.log=debug agent.debug_console agent.debug_console_vport=1026 agent.log=debug" \



