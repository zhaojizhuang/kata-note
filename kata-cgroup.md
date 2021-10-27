# kata 中的资源限制

kata 中 的资源限制分为两层
- 宿主机上
- vm 内

通过 configuration.toml 中的 `sandbox_cgroup_only=true or false` 来配置 cgroup
- 如果 `false` 
  - 宿主机上只对 qemu 线程做限制
  - 在宿主机上会把所有除了 qemu 线程之外的 线程放在 `/sys/fs/cgroup/< cgroup 类型，如 cpu memory>/kata_overehad/ `下，
    并且不做任何限制，用户可以自定义对它进行配置，如提前在这个目录下对 cpu memory 做限制

- 如果 `true` 宿主机上对 qemu,virtiofsd 等所有的组件都进行 cpu memory 限制

> podcgroup 目录中的 kata_< sandbox ID> 是为了兼容 docker 场景创建的，containerd 场景下 可以忽略

## 宿主机上的 cgroup 限制

宿主机上的 cgroup 是限制 container + overhead 的资源限制

宿主机上的路径 `/sys/fs/cgroup/< cgroup 类型，如 cpu memory>/kubepods/pod< Pod ID >/kata_< sand box ID>`

进程信息在 `cgroup.procs`，`task` 中的是线程

> 注意，如果 `sandbox_cgroup_only` 为 false，除了在上述路径中，
> 还会在 `/sys/fs/cgroup/< cgroup 类型，如 cpu memory>/kata_overhead/< sandbox ID>/` 中

## vm 内的 cgroup 限制

里面不对 pause 容器做限制，只对 业务 container做限制
`/sys/fs/cgroup/(memory or cpu)/kubepods/pod< pod ID>/<container ID>/`

