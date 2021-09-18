# 可观测性

## 1. 日志
日志适配

1. docker：
容器日志与日志 label 均从目录`/var/lib/docker/containers/<container-id>/xxx` 获取

2. container:
改为日志从`/var/log/containers` 获取，日志 label 从 kube-apiserver 获取

## 2. 监控


`$ kubectl apply -f https://raw.githubusercontent.com/kata-containers/kata-containers/main/docs/how-to/data/kata-monitor-daemonset.yml`
[Kata 2.0 Metrics Design](https://github.com/kata-containers/kata-containers/blob/main/docs/design/kata-2-0-metrics.md)
[monitor Kata Containers in Kubernetes](https://github.com/kata-containers/kata-containers/blob/main/docs/how-to/how-to-set-prometheus-in-k8s.md)