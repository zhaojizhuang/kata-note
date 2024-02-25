# 调试 kata

## agent-ctl

编译 agent-ctl

```bash
cd cd $GOPATH/src/github.com/kata-containers/kata-containers/tools/agent-ctl
make 
```
通过 vsock 连接 vm 中的 kata-agent

1. 获取 `guest_cid`

```bash
guest_cid=$(ps -ef | grep qemu-system-x86_64 | egrep -o "guest-cid=[0-9]*" | cut -d= -f2)
```

![](../images/guest-cid.png)

2. 连接 kata-agent

```bash
bundle_dir=/run/containerd/io.containerd.runtime.v2.task/k8s.io/1a35425c5f85543dcd94fdb9c744bc07677e7bfc712b55e039e99b149b42973d 
cd $GOPATH/src/github.com/kata-containers/kata-containers/tools/agent-ctl/target/x86_64-unknown-linux-musl/release

./kata-agent-ctl -l debug connect --bundle-dir "${bundle_dir}" --server-address "vsock://${guest_cid}:1024" -c Check -c GetGuestDetails

```

3. 查看 agent-ctl 示例

```bash
cd $GOPATH/src/github.com/kata-containers/kata-containers/tools/agent-ctl/target/x86_64-unknown-linux-musl/release
./kata-agent-ctl examples

EXAMPLES:

- Check if the agent is running:

  $ kata-agent-ctl connect --server-address "vsock://3:1024" --cmd Check

- Connect to the agent using local sockets (when running in same environment as the agent):

  # Local socket
  $ kata-agent-ctl connect --server-address "unix:///tmp/local.socket" --cmd Check

  # Abstract socket
  $ kata-agent-ctl connect --server-address "unix://@/foo/bar/abstract.socket" --cmd Check

- Query the agent environment:

  $ kata-agent-ctl connect --server-address "vsock://3:1024" --cmd GetGuestDetails

- List all available (built-in and Kata Agent API) commands:

  $ kata-agent-ctl connect --server-address "vsock://3:1024" --cmd list

- Generate a random container ID:

  $ kata-agent-ctl generate-cid

- Generate a random sandbox ID:

  $ kata-agent-ctl generate-sid

- Attempt to create 7 sandboxes, ignoring any errors:

  $ kata-agent-ctl connect --server-address "vsock://3:1024" --repeat 7 --cmd CreateSandbox

- Query guest details forever:

  $ kata-agent-ctl connect --server-address "vsock://3:1024" --repeat -1 --cmd GetGuestDetails

- Send a 'SIGUSR1' signal to a container process:

  $ kata-agent-ctl connect --server-address "vsock://3:1024" --cmd 'SignalProcess signal=usr1 sid=$sandbox_id cid=$container_id'

- Create a sandbox with a single container, and then destroy everything:

  $ kata-agent-ctl connect --server-address "vsock://3:1024" --cmd CreateSandbox
  $ kata-agent-ctl connect --server-address "vsock://3:1024" --bundle-dir "$bundle_dir" --cmd CreateContainer
  $ kata-agent-ctl connect --server-address "vsock://3:1024" --cmd DestroySandbox

- Create a Container using a custom configuration file:

  $ kata-agent-ctl connect --server-address "vsock://3:1024" --bundle-dir "$bundle_dir" --cmd 'CreateContainer spec=file:///tmp/config.json'
```


## 调试 agent

`kata-agent` 编译时间在 2 min 左右，加上制作 rootfs，编译 rootfs 镜像，一套流程下来要 20多分钟。
调试时可以通过 mount kata-containers.img 替换其中的  `kata-agent` 二进制, 秒级完成，节省宝贵的时间

```bash
#!/usr/bin/bash

agent="$GOPATH/src/github.com/kata-containers/kata-containers/src/agent/target/x86_64-unknown-linux-musl/debug/kata-agent"
img="$(realpath /opt/kata/share/kata-containers/kata-containers.img)"

dev="$( losetup --show -f -P "$img")"
echo "$dev"

part="${dev}p1"

mount $part /mnt1

install -b $agent /mnt1/usr/bin/kata-agent

 umount /mnt1

losetup -d "$dev"
```

另一种方式

```shell
fdisk -l kata-ubuntu-latest.image
# 找到 image  的 start,替换掉 6144
mount -o loop,offset=$[6144*512] kata-ubuntu-latest.image tmp3/
mkdir tmp2
cp -ar tmp3/* tmp2/

cp /data00/code/kata-containers/src/agent/target/debug/kata-agent tmp2/usr/bin/kata-agent
$GOPATH/src/github.com/kata-containers/kata-containers/tools/osbuilder/image-builder/image_builder.sh -o kata-ubuntu-spdk.image.img tmp2
```