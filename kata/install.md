## kata container 安装部署

> 版本 2.2.0

依赖于 containerd,如果之前是 Docker 安装的，可以参考[这篇文章]进行替换(https://mp.weixin.qq.com/s?__biz=MzU4MjQ0MTU4Ng==&mid=2247495053&idx=1&sn=cf1b685d347aa0ec793ca719f0f9ac14&chksm=fdbae290cacd6b866073bf26a5854a9cb67e5686810b8482ae0eadd7c38d8b107b6b3225c91b&mpshare=1&scene=1&srcid=0916wl1OB35uKPmFj1GcesQE&sharer_sharetime=1631781634683&sharer_shareid=9cf9ee6135f38546df3e013cc667681a&exportkey=AR8A6C2INCMXLOmbck1ZqAU%3D&pass_ticket=9A0OCej%2BFTrga%2B4dF7bsnBRjFlWhU8FFh4nt8OSdKHfQzLxRUOxtzrDUvbWj%2BnxJ&wx_header=0#rd)



参考 [Install Kata Containers with containerd](https://github.com/kata-containers/kata-containers/blob/main/docs/install/container-manager/containerd/containerd-install.md)

下载
```
wget -P / https://github.com/kata-containers/kata-containers/releases/download/2.2.0/kata-static-2.2.0-x86_64.tar.xz
cd /
tar xf kata-static-2.2.0-x86_64.tar.xz
```

将路径 `/opt/kata/bin` 添加到 系统PATH

## 为 containerd-shim-kata-v2 添加软连接

```bash
ln -s /opt/kata/bin/containerd-shim-kata-v2 /usr/local/bin/containerd-shim-kata-v2
```

> ！！注意，如果使用的是 cri-containerd-cni 压缩包，避免 与 /opt/kata/bin 下的 runc 冲突


## 修改 containerd 的 config.toml 
> Docker 中自带的 containerd 默认是将 CRI 这个插件禁用掉了
```bash
containerd config default > /etc/containerd/config.toml
```

1. sandbox 镜像修改

2. kata plugin 修改 ,参考官网[containerd install](https://github.com/kata-containers/kata-containers/blob/main/docs/install/container-manager/containerd/containerd-install.md)
```bash
[plugins]
  [plugins."io.containerd.grpc.v1.cri"]
    [plugins."io.containerd.grpc.v1.cri".containerd]
      default_runtime_name = "kata"
      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.kata]
          runtime_type = "io.containerd.kata.v2"
```

利用 ctr 测试
```bash
ctr image pull "docker.io/library/busybox:latest"
ctr run --runtime "io.containerd.kata.v2" --rm -t "docker.io/library/busybox:latest" test-kata uname -r
```


`K8s RuntimeClass`

```yaml
apiVersion: node.k8s.io/v1
handler: kata
kind: RuntimeClass
metadata:
  name: kata
overhead:
  podFixed:
    cpu: 100m
    memory: 256Mi
```

`busy box`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: busybox
  labels:
    app: busybox
spec:
  runtimeClassName: kata
  containers:
  - image: busybox
    command:
      - sleep
      - "3600"
    imagePullPolicy: IfNotPresent
    name: busybox
  restartPolicy: Always
```