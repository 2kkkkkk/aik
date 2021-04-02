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

FUNC_MUNU(){
echo -e "\033[33m*********MENU**********\033[0m"
echo -e "\033[33m1. 系统初始化\033[0m"
echo -e "\033[33m2. 卸载内核\033[0m"
echo -e "\033[33m3. 查看内核信息\033[0m"
echo -e "\033[33m4. EXIT\033[0m"
echo -e "\033[33m***********************\033[0m"
}

function FUNC_SYSTEM_CHECK() {
  VAR_SYSTEM_FLAG=$(/usr/bin/cat /etc/redhat-release | grep 'CentOS' | grep '7' | wc -l)
  if [[ ${VAR_SYSTEM_FLAG} -ne 1 ]];then
    FUNC_ECHO_ERROR '本脚本基于 [ CentOS 7 ] 编写，目前暂不支持其他版本系统！'
    exit 1001
else
    FUNC_ECHO_SUCCESS "系统版本[ CentOS 7 ]"
  fi
}

#############################################################################################
# 服务器联网函数
#############################################################################################
function FUNC_NETWORK_CHECK() {
  VAR_PING_NUM=$(/usr/bin/ping -c 3 www.baidu.com | grep 'icmp_seq' | wc -l)
  if [[ ${VAR_PING_NUM} -eq 0 ]];then
    FUNC_ECHO_ERROR '网络连接失败，请先配置好网络连接...'
    exit 1003
else
    FUNC_ECHO_SUCCESS "网络通信正常"
  fi
}


#############################################################################################
# 打印系统信息
#############################################################################################
function FUNC_PRINT_SYSTEM_INFO() {
  # 获取系统信息
  SYSTEM_DATE=$(/usr/bin/date)
  SYSTEM_VERSION=$(/usr/bin/cat /etc/redhat-release)
  SYSTEM_CPU=$(/usr/bin/cat /proc/cpuinfo | grep 'model name' | head -1 | awk -F: '{print $2}' | sed 's#^[ \t]*##g')
  SYSTEM_CPU_NUMS=$(/usr/bin/cat /proc/cpuinfo | grep 'model name' | wc -l)
  SYSTEM_KERNEL=$(/usr/bin/uname -a | awk '{print $3}')
  SYSTEM_IPADDR=$(/usr/sbin/ip addr | grep inet | grep -vE 'inet6|127.0.0.1' | awk '{print $2}')
    
  # 打印系统信息
  FUNC_ECHO_YELLOW ${LINE}
  echo "服务器的信息: ${SYSTEM_IPADDR}"
  FUNC_ECHO_YELLOW ${LINE}
  echo "操作系统版本: ${SYSTEM_VERSION}"
  echo "系统内核版本: ${SYSTEM_KERNEL}"
  echo "处理器的型号: ${SYSTEM_CPU}"
  echo "处理器的核数: ${SYSTEM_CPU_NUMS}"
  echo "系统当前时间: ${SYSTEM_DATE}"
  FUNC_ECHO_YELLOW ${LINE}
}

#############################################################################################
# 系统优化
#############################################################################################
function FUNC_INITALI() {

############# 检测当前系统是否具有合法IP地址############
yum install -y net-tools
conn=`ip a | grep "\<inet\>" | grep -v "127.0.0.1" | wc -l`

if [ $conn -eq 0 ]
then
     FUNC_ECHO_ERROR "未检测到当前合法IP地址，请检查网络连接..."   
     exit 123
fi

IP=`ifconfig | sed -n '2{p}' | awk '{print $2}'`
ETH=`ifconfig  | sed -n '1{p}' | tr ':' ' ' | awk '{print $1}'`
GATE="`echo $IP | awk -F "." '{print $1"."$2"."$3"."}'`254"

cat > /etc/sysconfig/network-scripts/ifcfg-$ETH <<EOF
TYPE=Ethernet
BOOTPROTO=static
NAME=$ETH
DEVICE=$ETH
IPADDR="$IP"
PREFIX=24
GATEWAY=$GATE
ONBOOT=yes
DNS1=172.16.163.54
EOF


#修改字符集
sed -i 's/LANG="en_US.UTF-8"/LANG="zh_CN.UTF-8"/' /etc/locale.conf

#Yum源更换为国内阿里源
yum install wget telnet -y
if [ `cat /etc/yum.repos.d/CentOS-Base.repo|egrep "baseurl=http://mirrors.aliyun.com"|wc -l` -eq 0 ];then
	mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
	wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
fi

if [ `cat /etc/yum.repos.d/epel.repo|egrep "baseurl=http://mirrors.aliyun.com"|wc -l` -eq 0 ];then
	#添加阿里的epel源
	#add the epel
	wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
	# rpm -ivh http://dl.Fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-8.noarch.rpm
fi
	#yum重新建立缓存
	yum clean all
	yum makecache

#同步时间
yum -y install ntp
/usr/sbin/ntpdate cn.pool.ntp.org
if [ `crontab -l |egrep "\* 4 \* \* \* \/usr/sbin/ntpdate cn\.pool\.ntp\.org"|wc -l` -eq 0 ];then
	echo "* 4 * * * /usr/sbin/ntpdate cn.pool.ntp.org > /dev/null 2>&1" >> /var/spool/cron/root
	systemctl  restart crond.service
fi

#安装vim，可适当添加vim配置和rz
yum -y install vim lrzsz

#设置最大打开文件描述符数
if [ `cat /etc/rc.local|egrep "^ulimit -SHn 102400$"|wc -l` -eq 0 ];then
	echo "ulimit -SHn 102400" >> /etc/rc.local
fi

if [ `cat /etc/security/limits.conf|egrep "^\*"|egrep "soft"|wc -l` -eq 0 ];then
	echo "*           soft   nofile       655350" >> /etc/security/limits.conf
fi

if [ `cat /etc/security/limits.conf|egrep "^\*"|egrep "hard"|wc -l` -eq 0 ];then
	echo "*           hard   nofile       655350" >> /etc/security/limits.conf
fi

#禁用selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
setenforce 0

#关闭防火墙
systemctl disable firewalld.service 
systemctl stop firewalld.service 

#配置 ssh
sed -i 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config   #禁止DNS反向解析客户端
systemctl  restart sshd.service


#建立普通用户
if [ `id space 2>&1|wc -l` -eq 0 ];then
	spacepass="space@123"
	useradd space && echo $spacepass | passwd --stdin space
fi

if [ `id sby 2>&1|wc -l` -eq 0 ];then
sbypass="sby@123"
useradd sby && echo $sbypass | passwd --stdin sby
echo "sby   ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
fi


yum -y update 
FUNC_ECHO_INFO "------------------优化完成--------------------"

rebot=`echo -e "\e[1;42m是重启系统（默认 y） [y/n]: \e[0m"`
read -p "$rebot: " REBOOT
case ${REBOOT} in
  [yY][eE][sS]|[yY])
     reboot
  ;;
  [nN][oO]|[nN])
    FUNC_ECHO_YELLOW "正在退出,请记得卸载旧内核..."
    FUNC_UNINSTALL_KERNEL
    exit
  ;;
  *)
    reboot
esac


}

#############################################################################################
# 提示卸载旧版本内核
#############################################################################################
function FUNC_UNINSTALL_KERNEL() {
    # 显示内核版本
    FUNC_ECHO_INFO "系统当前所安装的内核版本如下："
    rpm -qa | grep kernel
    
    # 提示卸载
    FUNC_ECHO_INFO "你可以手动卸载旧版本：yum -y remove 包名字，然后重启使用：uname -r 查看升级结果"
}

#############################################################################################
# 卸载内核
#############################################################################################
function FUNC_REMOVE() {

kernel1160=`rpm -qa | grep  kernel-3.10.0-1160*  | wc -l`
if [ $kernel1160 -eq 0 ]
then
     FUNC_ECHO_ERROR "内核未更新，请检查"   
     exit 123
 else
 	FUNC_ECHO_INFO "内核已更新"
 	kernel957=`rpm -qa | grep  kernel-3.10.0-957*  | wc -l`
 	if [ $kernel957 -eq 0 ] 
 	then
 		FUNC_ECHO_ERROR "内核未更新，请检查"
 		exit 123
  else
 	  FUNC_ECHO_INFO "开始卸载旧内核"
 	  yum -y remove kernel-3.10.0-957.el7.x86_64
  fi
fi
 

}

function main (){

# 系统检查
FUNC_SYSTEM_CHECK
# 联网检测
FUNC_NETWORK_CHECK
# 打印系统信息
FUNC_PRINT_SYSTEM_INFO

INIT=`echo -e "\e[1;42m是否开始系统优化（默认 y） [y/n]: \e[0m"`
read -p "$INIT: " VAR_CHOICE
case ${VAR_CHOICE} in
  [yY][eE][sS]|[yY])
     FUNC_INITALI
  ;;
  [nN][oO]|[nN])
    FUNC_ECHO_YELLOW "系统优化即将终止..."
    exit
  ;;
  *)
    FUNC_INITALI
esac

}

while true
  do
  FUNC_MUNU
  INIT=`echo -e "\e[1;35m输入菜单编号选择安装: \e[0m"`
  read -e -p "$INIT" inst
  case $inst in
    1)
    main
    ;;
    2)
    FUNC_REMOVE
    ;;
    3)
    FUNC_UNINSTALL_KERNEL
    ;;
    4)
    exit
    ;;
    *)
    FUNC_ECHO_ERROR "输入错误"
  esac
done
