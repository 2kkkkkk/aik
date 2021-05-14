#!/bin/bash

#############################################################################################
# 导入系统变量
#############################################################################################
. /etc/init.d/functions
source /etc/profile

#############################################################################################
# 服务变量定义
#############################################################################################
# 线条
LINE='---------------------------------------------------------------------------------------'



#############################################################################################
# 颜色输出函数
#############################################################################################
function FUNC_COLOR_TEXT() {
  echo -e " \e[0;$2m$1\e[0m"
}

function FUNC_ECHO_RED() {
  echo $(FUNC_COLOR_TEXT "$1" "31")
}

function FUNC_ECHO_GREEN() {
  echo $(FUNC_COLOR_TEXT "$1" "32")
}

function FUNC_ECHO_YELLOW() {
  echo $(FUNC_COLOR_TEXT "$1" "33")
}

function FUNC_ECHO_BLUE() {
  echo $(FUNC_COLOR_TEXT "$1" "34")
}

#############################################################################################
# 颜色通知输出函数
#############################################################################################
# 通知信息
function FUNC_ECHO_INFO() {
  echo $(FUNC_COLOR_TEXT "${LINE}" "33")
  echo $(FUNC_COLOR_TEXT "$1" "33")
  echo $(FUNC_COLOR_TEXT "${LINE}" "33")
}

# 完成信息
function FUNC_ECHO_SUCCESS() {
  echo $(FUNC_COLOR_TEXT "${LINE}" "32")
  echo $(FUNC_COLOR_TEXT "$1" "32")
  echo $(FUNC_COLOR_TEXT "${LINE}" "32")
}

# 错误信息
function FUNC_ECHO_ERROR() {
  echo $(FUNC_COLOR_TEXT "${LINE}" "31")
  echo $(FUNC_COLOR_TEXT "$1" "31")
  echo $(FUNC_COLOR_TEXT "${LINE}" "31")
}

#############################################################################################
# 菜单选择函数
#############################################################################################
function FUNC_MUNU(){
echo -e "\033[33m*********MENU**********\033[0m"
echo -e "\033[33m1. ALL INSTALL\033[0m"
echo -e "\033[33m2. INSTALL Python\033[0m"
echo -e "\033[33m3. INSTALL Ansible\033[0m"
echo -e "\033[33m4. INSTALL K9S\033[0m"
echo -e "\033[33m5. INSTALL Mycli\033[0m"
echo -e "\033[33m0. EXIT\033[0m"
echo -e "\033[33m***********************\033[0m"
}

py_pyth="/usr/local/python3"
pak_v="Python-3.*"

#############################################################################################
# Python3安装函数
#############################################################################################

function FUNC_PY3(){
#安装python3
if [ ! -f $pak_v.tar.xz ];then
	FUNC_ECHO_INFO "未发现Python安装包，准备在线下载！"
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
		ln -sf $py_pyth/bin/python3.8 /usr/local/bin/python3
		ln -sf $py_pyth/bin/pip3.8 /usr/local/bin/pip3
		FUNC_ECHO_SUCCESS "当前python安装版本: `/usr/local/bin/python3 --version`"
	else
		FUNC_ECHO_ERROR -n "编译安装失败，退出码："
		exit 2
	fi
fi


}


function FUNC_MYCLI(){
which mycli >/dev/null 2>&1
if [ `echo $?` -ne 0 ];then
	FUNC_ECHO_INFO "开始安装Mycli！"
	/usr/local/bin/pip3 install mycli -i https://mirrors.aliyun.com/pypi/simple/
	if [ `echo $?` -eq 0 ];then
		ln -s /usr/local/python3/bin/mycli  /usr/local/bin/mycli
	fi
fi
}

function FUNC_K9S(){
k9s version > /dev/null 2>&1
if [ `echo $?` -ne 0 ];then
	if [ ! -f k9s_Linux_x86_64.tar.gz ];then
		FUNC_ECHO_INFO "准备下载K9S..."
		wget https://github.com.cnpmjs.org/derailed/k9s/releases/download/v0.24.6/k9s_Linux_x86_64.tar.gz > /dev/null 2>&1
		if [ `echo $?` -ne 0 ];then
			FUNC_ECHO_ERROR "下载失败，将退出"
			break
		fi
	fi
	tar zxf k9s_Linux_x86_64.tar.gz k9s
	mv ./k9s /usr/local/bin/k9s
	chmod +x /usr/local/bin/k9s
	FUNC_ECHO_SUCCESS " 当前K9S安装版本为： `/usr/local/bin/k9s version|grep 'Version:'`"
fi


}

function FUNC_ANSIBLE(){
#安装ansible
/usr/bin/which ansible >/dev/null 2>&1
if [ `echo $?` -eq 0 ];then
	FUNC_ECHO_SUCCESS "当前ansible已安装版本是：`/usr/local/bin/ansible --version|head -n 1`"
else
	FUNC_ECHO_INFO "开始安装ansible..."
	/usr/local/bin/pip3 install ansible -i https://mirrors.aliyun.com/pypi/simple/
	/usr/local/bin/pip3 install netaddr -i https://mirrors.aliyun.com/pypi/simple/
	yum -y install sshpass
	ln -s /usr/local/python3/bin/ansible-playbook  /usr/local/bin/ansible-playbook
	ln -s /usr/local/python3/bin/ansible  /usr/local/bin/ansible
	FUNC_ECHO_SUCCESS "当前ansible安装版本是：`/usr/local/bin/ansible --version|head -n 1`"
fi
}



while true
do
FUNC_MUNU
menu=`echo -e "\e[1;42m输入菜单编号选择安装：: \e[0m"`
read -e -p "$menu" inst
case $inst in
1)
	FUNC_PY3
	FUNC_MYCLI
	FUNC_ANSIBLE
	;;
2)
	FUNC_PY3
	;;
3)
	FUNC_ANSIBLE
	;;
4)
	FUNC_K9S
	;;
5)
	FUNC_MYCLI
	;;	
0)
	exit
	;;
*)
	FUNC_ECHO_ERROR "输入错误"
esac
done

