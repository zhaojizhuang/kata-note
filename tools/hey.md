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



