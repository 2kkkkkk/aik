# Kubernetes 企业级高可用集群
``` 
支持的kubernetes版本：v1.18 v1.19
```
### 1、找一台服务器安装Ansible
```
#执行python3和ansible安装脚本
/bin/bash install_py3.sh
#执行内核更新脚本 （可选 内核选择ml）
/bin/bash kernel_update.sh
#执行系统初始化脚本 （可选 需要更改DNS信息）
/bin/bash linux_initali.sh
```
### 2、下载所需文件

下载Ansible部署文件：

```
# git clone https://gitee.com/Zheng--Kai/aik.git
# cd aik
```

下载准备好软件包并解压/root目录：

链接: 链接：https://pan.baidu.com/s/1kkPAR0xFztB2yepe4t7yRg

提取码: 2kkk

```
# tar zxf binary_pkg.tar.gz
```
### 3、修改Ansible文件

修改hosts文件，根据规划修改对应IP和名称。

```
# vim hosts
[master]
# 如果部署单Master，只保留一个Master节点
# 默认Naster节点也部署Node组件
172.16.163.111 node_name=k8s-master1 hostname=k8s-master1
172.16.163.112 node_name=k8s-master2 hostname=k8s-master2
172.16.163.113 node_name=k8s-master3 hostname=k8s-master3

[node]
172.16.163.114 node_name=k8s-node1 hostname=k8s-node1
172.16.163.115 node_name=k8s-node2 hostname=k8s-node2

[etcd]
172.16.163.111 etcd_name=etcd-1 hostname=k8s-master1
172.16.163.112 etcd_name=etcd-2 hostname=k8s-master2
172.16.163.113 etcd_name=etcd-3 hostname=k8s-master3

[lb]
# 如果部署单Master，该项忽略
172.16.163.111 lb_name=lb-master hostname=k8s-master1
172.16.163.112 lb_name=lb-backup hostname=k8s-master2

[k9s]
#k9s:k8s 集群管理的工具,哪个IP要就写哪个
172.16.163.100 hostname=k8s-client100
172.16.163.111
172.16.163.112
172.16.163.113

#harbor 仓库, docker私人仓库
[harbor]
#172.16.163.43 hostname=harbor

[k8s:children]
master
node

[newnode]
#172.16.163.106 node_name=k8s-node3

# 测试
ansible -i hosts all  -m shell -a "date" -uroot -k
...
```
修改group_vars/all.yml文件，修改软件包目录和容器引擎,网络插件方案还有证书可信任IP。
其他参数都有备注。
```
# vim group_vars/all.yml
#K9s - Kubernetes CLI管理K8s集群,不许要安装设置为false
k9s_install: true

# 支持的集群容器引擎: docker, containerd
container_runtime: docker

# 选择网络插件方案 
addons_Option_I: true
addons_Option_II: false

# 网络插件选择 calico flannel cilium
network_plugin: calico

#安装包目录
software_dir: '/root/binary_pkg'
...
#证书可信任ip
cert_hosts:
  k8s:
  etcd:
```
## 4、一键部署
### 架构图
单Master架构
![avatar](https://images.gitee.com/uploads/images/2021/0225/170713_ee8dbfa8_8721850.jpeg "single-master.jpg")

多Master架构
![avatar](https://images.gitee.com/uploads/images/2021/0225/170745_b7ba1da3_8721850.jpeg "multi-master.jpg")

###Containerd容器引擎 

多Master版：
```
# ansible-playbook -i hosts multi-master-containerd.yml -uroot -k
```
单Master版：
```
# ansible-playbook -i hosts single-master-containerd.yml -uroot -k
```

###Docker容器引擎 1.23版本弃用

多Master版：
```
# ansible-playbook -i hosts multi-master-docker.yml -uroot -k
```
单Master版：
```
# ansible-playbook -i hosts single-master-docker.yml -uroot -k
```
###Harbor仓库安装
```
# ansible-playbook -i hosts harbor.yml -uroot -k
```
## 5、部署控制
如果安装某个阶段失败，可针对性测试.

例如：只运行部署插件
```
# ansible-playbook -i hosts single-master-docker.yml -uroot -k --tags addons
```

## 6、节点扩容
1）修改hosts，添加新节点ip
```
# vim hosts
[newnode]
172.16.163.100 node_name=k8s-node3
```
2）执行部署
```
ansible-playbook -i hosts add-node.yml -uroot -k
```
## 7、所有HTTPS证书存放路径
```
部署产生的证书都会存放到目录“aik/ssl”
```