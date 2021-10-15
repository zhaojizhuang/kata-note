# vmcache 

开启 vmcache 需要 initrd 类型的image

修改 kata 的配置文件

```bash
#  vi /opt/kata/share/defaults/kata-containers/configuration.toml

[hypervisor.qemu]
path = "/opt/kata/bin/qemu-system-x86_64"
kernel = "/opt/kata/share/kata-containers/vmlinuz.container"
#image = "/opt/kata/share/kata-containers/kata-containers.img"
initrd = "/opt/kata/share/kata-containers/kata-containers-initrd.img"

[factory]
enable_template = true
shared_fs = virtio-9p # vmcache 暂时不支持 vitio-fs
vm_cache_number = 3 # 这里是 vm cache 的大小
```

宿主机运行
```bash
kata-runtime factory init  # 初始化
kata-runtime factory status # 查看状态
kata-runtime factory destroy # 删除 vm 池
```

**注意：vmcache 暂时不支持 virtio-fs，见[社区文档](https://github.com/kata-containers/kata-containers/blob/main/docs/how-to/what-is-vm-templating-and-how-do-I-use-it.md),**

