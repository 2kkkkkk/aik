#!/bin/bash

munu(){
cat << EOF
*********MENU**********
 1. ALL INSTALL
 2. INSTALL Python
 3. INSTALL Ansible
 4. EXIT
***********************
EOF
}

py_pyth="/usr/local/python3"
pak_v="Python-3.*"

py3(){
#安装python3
if [ ! -f $pak_v.tar.xz ];then
	echo "未发现Python安装包，准备在线下载！"
	/usr/bin/which wget >/dev/null 2>&1
	if [ `echo $?` -ne 0 ];then
		yum -y install wget >/dev/null 2>&1
	fi
	/usr/bin/wget https://repo.huaweicloud.com/python/3.8.8/Python-3.8.8.tar.xz >/dev/null 2>&1
	tar xf $pak_v.tar.xz
else
	tar xf $pak_v.tar.xz
fi

yum -y install gcc-c++ zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel libffi-devel > /dev/null 2>&1
if [ `echo $?` -eq 0 ];then
	cd $pak_v/
	./configure --prefix=/usr/local/python3 --with-ssl 
	make && make install
	if [ `echo $?` -eq 0 ];then
		ln -sf $py_pyth/bin/python3.8 /usr/bin/python3
		ln -sf $py_pyth/bin/pip3.8 /usr/bin/pip3
		echo "当前python安装版本: `/usr/bin/python3 --version`"
	else
		echo -n "编译安装失败，退出码："
		exit 2
	fi
fi
}


asb(){
#安装ansible
/usr/bin/which ansible >/dev/null 2>&1
if [ `echo $?` -eq 0 ];then
	echo "当前ansible已安装版本是：`ansible --version|head -n 1`"
else
	/usr/bin/pip3 install ansible -i https://mirrors.aliyun.com/pypi/simple/
	/usr/bin/pip3 install netaddr -i https://mirrors.aliyun.com/pypi/simple/
	yum -y install sshpass
	ln -s /usr/local/python3/bin/ansible-playbook  /usr/bin/ansible-playbook
	ln -s /usr/local/python3/bin/ansible  /usr/bin/ansible
	echo "当前ansible安装版本是：`ansible --version|head -n 1`"
fi
}

while true
	do
	munu
	read -e -p "输入菜单编号选择安装：" inst
	case $inst in
		1)
		py3
		asb
		;;
		2)
		py3
		;;
		3)
		asb
		;;
		4)
		exit
		;;
		*)
		echo "输入错误"
	esac
done
