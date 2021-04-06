# 压测 hey

#### 制作 hey 镜像

#### 1. 容器中执行  `go get`  

```text
docker run golang go get -v github.com/rakyll/hey
```

#### 2. 将容器打镜像

```text
docker commit $(docker ps -lq) zhaojizhuang66/heyimage
```

#### 3. docker 中使用 

```text
docker run zhaojizhuang66/heyimage hey -n 10 -c 2 'https://json-head.now.sh/'
```

#### 4. k8s 中使用

```yaml
cat << EOF > hey.yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: hey
  name: hey
spec:
  containers:
    # This could be any image that we can SSH into and has curl. radial/busyboxplus:curl
  - image: zhaojizhuang66/heyimage
    imagePullPolicy: IfNotPresent
    name: hey
    resources: {}
    stdin: true
    tty: true
EOF
```

```yaml
kubectl create -f hey.yaml
```

等待 Pod Ready 后执行

```yaml
kubectl exec -it hey bash

root@hey:/# hey -n 10 -c 2 'https://json-head.now.sh/'
```

结果

```yaml

Summary:
  Total:	4.7720 secs
  Slowest:	3.9010 secs
  Fastest:	0.2000 secs
  Average:	0.9497 secs
  Requests/sec:	2.0955

  Total data:	7450 bytes
  Size/request:	745 bytes

Response time histogram:
  0.200 [1]	|■■■■■■
  0.570 [7]	|■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  0.940 [0]	|
  1.310 [0]	|
  1.680 [0]	|
  2.050 [0]	|
  2.421 [0]	|
  2.791 [0]	|
  3.161 [0]	|
  3.531 [0]	|
  3.901 [2]	|■■■■■■■■■■■


Latency distribution:
  10% in 0.2081 secs
  25% in 0.2156 secs
  50% in 0.2226 secs
  75% in 3.8690 secs
  90% in 3.9010 secs
  0% in 0.0000 secs
  0% in 0.0000 secs

Details (average, fastest, slowest):
  DNS+dialup:	0.4771 secs, 0.2000 secs, 3.9010 secs
  DNS-lookup:	0.4026 secs, 0.0000 secs, 2.0134 secs
  req write:	0.0000 secs, 0.0000 secs, 0.0002 secs
  resp wait:	0.4724 secs, 0.1998 secs, 1.5068 secs
  resp read:	0.0002 secs, 0.0001 secs, 0.0006 secs

Status code distribution:
  [200]	10 responses


```

