# Kubernetes 企业级高可用集群
``` 
支持的kubernetes版本：v1.19 v1.20
```
### 1、找一台服务器安装Ansible
```
# 需要安装python3 用pip3安装ansible
#python3安装
1.依赖包安装
yum -y  install gcc-c++
yum -y install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel libffi-devel
2.下载包：
#下载路径(里面有不同的版本)https://www.python.org/ftp/python/3.8.8/
#下载命令
wget https://www.python.org/ftp/python/3.8.8/Python-3.8.8.tar.xz
3.解压：
tar -zxvf Python-3.8.8.tar.xz
4.安装：
cd Python-3.8.8
#指定编译目录
mkdir /usr/local/python3
./configure --prefix=/usr/local/python3 --with-ssl
#编译安装
make && make install
5.建立软连接
ln -s /usr/local/python3/bin/python3.8 /usr/bin/python3
ln -s /usr/local/python3/bin/pip3.8 /usr/bin/pip3  没有pip直接就pip
6.测试一下python3是否可以用
python3
pip3
安装ansible
pip install ansible -i https://mirrors.aliyun.com/pypi/simple/
#ansible需要sshpass
yum -y install sshpass
#ansible配置文件
https://raw.githubusercontent.com/ansible/ansible/devel/examples/ansible.cfg
#ansible需要sshpass
yum -y install sshpass
#软链接ansible-playbook
ln -s /usr/local/python3/bin/ansible-playbook  /usr/bin/ansible-playbook
#软链接
ln -s /usr/local/python3/bin/ansible  /usr/bin/ansible
# 安装netaddr模块
pip install netaddr -i https://mirrors.aliyun.com/pypi/simple/

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
# vi hosts
[master]
172.16.163.111 node_name=k8s-master1 hostname=k8s-master1
[node]
172.16.163.114 node_name=k8s-node1 hostname=k8s-node1
[etcd]
172.16.163.111 etcd_name=etcd-1 hostname=k8s-master1
[lb]
# 如果部署单Master，该项忽略
172.16.163.111 lb_name=lb-master hostname=k8s-master1
#用于添加节点
[newnode]
#172.16.163.106 node_name=k8s-node3

# 测试
ansible -i hosts all  -m shell -a "date" -uroot -k
...
```
修改group_vars/all.yml文件，修改软件包目录和证书可信任IP。
其他参数都有备注，注意ip是对的 网络保持一致
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

###Containerd容器引擎 待开发

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