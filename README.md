# Kubernetes 高可用集群自动部署 二进制 
>### 确保所有节点系统时间一致

### 1、找一台服务器安装Ansible
```
# 需要安装python3 用pip3安装ansible
# 安装netaddr模块
pip install netaddr -i https://mirrors.aliyun.com/pypi/simple/

```
### 2、下载所需文件

下载Ansible部署文件：

```
# git clone 
# cd 

```

下载准备好软件包并解压/root目录：

只对1.19.8进行安装测试

链接: https://pan.baidu.com/s/1U-566cbdqXGOP7JEkB5Y1g

提取码: 2kkk

```
# tar zxf binary_pkg.tar.gz
```
### 3、修改Ansible文件

修改hosts文件，根据规划修改对应IP和名称。

```
# vi hosts
...
```
修改group_vars/all.yml文件，修改软件包目录和证书可信任IP。

```
# vim group_vars/all.yml
software_dir: '/root/binary_pkg'
...
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

单Master版：
```
# ansible-playbook -i hosts single-master-deploy.yml -uroot -k
```
多Master版：
```
# ansible-playbook -i hosts multi-master-deploy.yml -uroot -k
```

## 5、部署控制
如果安装某个阶段失败，可针对性测试.

例如：只运行部署插件
```
# ansible-playbook -i hosts single-master-deploy.yml -uroot -k --tags addons
```

## 6、节点扩容
1）修改hosts，添加新节点ip
```
# vi hosts
```
2）执行部署
```
ansible-playbook -i hosts add-node.yml -uroot -k
```
3）在Master节点允许颁发证书并加入集群
```
kubectl get csr
kubectl certificate approve node-csr-xxx
```
