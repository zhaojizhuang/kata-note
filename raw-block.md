# kata 支持块设备


## 1. 本机创建块设备
> 利用 内核模块 brd 创建 ramdisk 块设备
### 1. 本机创建块设备

在 /dev 目录下穿件 2 个 20M 的 块设备
```bash
modprobe brd rd_nr=2 rd_size=20480 max_part=0

# 查看ramdisk，可以看到类型为  b，也就是块设备 block
root@~:~# ls -al /dev/ram*
brw-rw---- 1 root disk 1, 0 Sep 29 11:14 /dev/ram0
brw-rw---- 1 root disk 1, 1 Sep 29 11:14 /dev/ram1
```
### 2. 分区 

```bash
fdisk /dev/ram0 
# n ,创建 分区，然后一路默认，最后 w 保存
```


## 2. 创建 local pv 与 pvc ，pod

- `storage class`

```yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
```

- `pv.yaml`

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ramdisk0
spec:
  capacity:
    storage: 20Mi
  volumeMode: Block
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  storageClassName: local-storage
  local:
    path: /dev/ram0
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - node
```

- `pvc.yaml`

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: block-pvc
spec:
  storageClassName: local-storage
  accessModes:
    - ReadWriteOnce
  volumeMode: Block
  resources:
    requests:
      storage: 20Mi
```

- `Pod.yaml` 

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: busybox-vm-block
  labels:
    name: busybox-vm-block
spec:
  runtimeClassName: kata
  restartPolicy: Never
  containers:
    - resources:
        limits :
          cpu: 0.5
      image: busybox
      command:
        - "/bin/sh"
        - "-c"
        - "while true; do date; sleep 1; done"
      name: busybox
      volumeDevices:
        - name: vol
          devicePath: /dev/xvda
  volumes:
      - name: vol
        persistentVolumeClaim:
          claimName: block-pvc
```


## 3. 进入 pod 查看

```bash
kubectl exec -it busybox-vm-block sh

/ # ls -al /dev/xvda
brw-rw----    1 root     disk        8,   0 Sep 29 03:35 /dev/xvda

/ # stat /dev/xvda
  File: /dev/xvda
  Size: 0         	Blocks: 0          IO Block: 4096   block special file
Device: 2bh/43d	Inode: 16          Links: 1     Device type: 8,0
Access: (0660/brw-rw----)  Uid: (    0/    root)   Gid: (    6/    disk)
Access: 2021-09-29 03:35:09.023481491 +0000
Modify: 2021-09-29 03:35:09.023481491 +0000
Change: 2021-09-29 03:35:09.023481491 +0000

```


[k8s hostpath 和 localpv](https://www.cnblogs.com/ssgeek/p/13690147.html)
[k8s raw block volume](https://kubernetes.io/zh/docs/concepts/storage/persistent-volumes/#raw-block-volume-support)