#!/usr/bin/env bash
################################################################
#                                                              #
# This is a router installation for Linux                      #
# Version: 0.0.1 20200114                                      #
# Author: Ksana410                                             #
# Website: https://Ksana410.github.io                          #
#                                                              #
################################################################

# Version: 0.0.1 20200114
# *创建日期，初始编写

# 前期安装说明，为了减少冲突，建议使用纯净安装后的Linux发行版作为母体系统进行安装
echo "${Yellow}################################################################${Reset}"
echo "${Yellow}#                                                              #${Reset}"
echo "${Yellow}# This is a router installation for Linux                      #${Reset}"
echo "${Yellow}# Version: 0.0.1 20200114                                      #${Reset}"
echo "${Yellow}# Author: Ksana410                                             #${Reset}"
echo "${Yellow}# Website: https://Ksana410.github.io                          #${Reset}"
echo "${Yellow}#                                                              #${Reset}"
echo "${Yellow}################################################################${Reset}"
echo "${Red}----------------------------------------------------------------${Reset}"
echo "${Red}To avoid unnecessary conflicts, it is recommended to use a      ${Reset}"
echo "${Red}pure installation of Linux for operation                        ${Reset}"
echo "${Red}----------------------------------------------------------------${Reset}"



# 初始化变量
OS=''
VER=''
MACHINE=''
PKM=''

# 网络参数
NET_NAME_TYPE=''
WANNET_TYPE='dhcp'
WANNET_NAME=''
LANNET_TYPE='static'
LANNET_NAME=''
LANNET_IP=''
LANNET_MASK=''
LANNET_GATEWAY=''
DEFAULT_VLAN=''
KERNEL_VERSION=''

# 颜色输出
Red=$(tput setaf 1)
Green=$(tput setaf 2)
Yellow=$(tput setaf 3)
Blue=$(tput setaf 4)
Purple=$(tput setaf 5)
Reset=$(tput sgr0)

# 依赖包
packageList=(dnsmasq wget curl unzip)

# 检测是否是Root用户
if [[ $(id -u) != "0" ]]; then
    printf "\e[42m\e[31m Error: You must be root to run this install script.\e[0m\n"
    exit 1
fi

# if [ $(whoami) != 'root' ];then
#    echo `date "+%Y/%m/%d %H:%M:%S> "` "必须用 root 账户执行此脚本！"
#    exit
#fi
   
# 检测Linux发行版及架构，主要测试Debian,Ubuntu,CentOS,RedHat,Alpine,Rocky，其他发行版暂不支持，做出相应的警告并自动退出，支持的系统测试包管理器类型
sysCheck(){
    echo "${Green}Checking system...${Reset}"
    MACHINE=$(uname -m)
    # 测试支持的Linux发行版，及其包管理器（package manager）
    if [[ -f /etc/redhat-release ]]; then
        $OS="centos"
        $PKM="yum"
    elif grep -Eqi "debian|raspbian" /etc/issue; then
        $OS="debian"
        $PKM="apt"
    elif grep -Eqi "ubuntu" /etc/issue; then
        $OS="ubuntu"
        $PKM="apt"
    elif grep -Eqi "centos|red hat|redhat" /etc/issue; then
        $OS="centos"
        $PKM="yum"
    elif grep -Eqi "debian|raspbian" /proc/version; then
        $OS="debian"
        $PKM="apt"
    elif grep -Eqi "ubuntu" /proc/version; then
        $OS="ubuntu"
        $PKM="apt"
    elif grep -Eqi "centos|red hat|redhat" /proc/version; then
        $OS="centos"
        $PKM="yum"
    else
        echo "${Red}This script is not supported by your system!${Reset}"
        exit 1
    fi
}


# 生成配置文件

# 安装必要组件
install_pack() {
    PKM install git
}

# 下载组件

# 选择需要实现的功能

# 添加防火墙规则
