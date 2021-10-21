# 可观测性

## 1. 日志
日志适配

1. docker：
容器日志与日志 label 均从目录`/var/lib/docker/containers/<container-id>/xxx` 获取

2. container:
改为日志从`/var/log/containers` 获取，日志 label 从 kube-apiserver 获取

## 2. 监控

> 前提是部署好 prometheus 和 grafana

### 1. 部署 kata-monitor

```bash
kubectl apply -f https://raw.githubusercontent.com/kata-containers/kata-containers/main/docs/how-to/data/kata-monitor-daemonset.yml
```

### prometheus 添加抓取规则
```yaml
spec:
  additionalScrapeConfigs:
  - job_name: 'kata'
    static_configs:
    - targets: ['localhost:8090']
```

### 2. 配置 Grafana dashboard 面板 

导入 `https://raw.githubusercontent.com/kata-containers/kata-containers/main/docs/how-to/data/dashboard.json` dashboard

## kata 支持的 指标 


`https://github.com/kata-containers/kata-containers/blob/main/docs/design/kata-2-0-metrics.md`

2. [Kata 2.0 Metrics Design](https://github.com/kata-containers/kata-containers/blob/main/docs/design/kata-2-0-metrics.md)
3. [monitor Kata Containers in Kubernetes](https://github.com/kata-containers/kata-containers/blob/main/docs/how-to/how-to-set-prometheus-in-k8s.md)