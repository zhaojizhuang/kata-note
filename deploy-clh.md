## 部署 cloudhypervisor

新建文件 `/usr/local/bin/containerd-shim-kata-clh-v2`

内容如下:

```shell
#!/bin/bash
KATA_CONF_FILE=/opt/kata/share/defaults/kata-containers/configuration-clh.toml /usr/local/bin/containerd-shim-kata-v2 $@
```

### 启动容器
```shell
ctr i pull docker.io/library/ubuntu:14.04
ctr  run --runtime "io.containerd.kata-clh.v2"  --rm -t "docker.io/library/ubuntu:14.04" test-kata uname -r
```


## 接入 CRI
> ctr 命令本身是不读取 /etc/containerd/config.toml 命令的，是通过 sdk 访问 containerd 的
> 如果是通过 containerd 接入 k8s，还需要配置下 `/etc/containerd/config.toml`
> 
> 