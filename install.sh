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

# 初始化变量
OS=''
VER=''
MACHINE=''

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
   
# 检测Linux发行版及架构
sysCheck(){
    echo -e "\033[31m Checking System... \033[0m"
    if [[ -z $OS ]] || [[ -z $VER ]]; then
        MACHINE=$(uname -m)
        if [ -f /etc/os-release ]; then
            # freedesktop.org and systemd
            . /etc/os-release
            OS=$NAME
            VER=$VERSION_ID
        elif type lsb_release >/dev/null 2>&1; then
            # linuxbase.org
            OS=$(lsb_release -si)
            VER=$(lsb_release -sr)
        elif [ -f /etc/lsb-release ]; then
            # For some versions of Debian/Ubuntu without lsb_release command
            . /etc/lsb-release
            OS=$DISTRIB_ID
            VER=$DISTRIB_RELEASE
        elif [ -f /etc/debian_version ]; then
            # Older Debian/Ubuntu/etc.
            OS=Debian
            VER=$(cat /etc/debian_version)
        elif [ -f /etc/rocky-release ]; then
            # For Rocky Linux
            OS=Rocky
            VER=$(cat /etc/rocky-release|awk '{print $4}')
        elif [ -f /etc/redhat-release ]; then
            # Older Red Hat, CentOS, etc.
            OS=RedHat
            VER=$(cat /etc/redhat-release)
        else
            # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
            OS=$(uname -s)
            VER=$(uname -r)
        fi
    fi
}

# 生成配置文件

# 安装必要组件
install_pack() {
    systemPackage install git
}

# 下载组件

# 选择需要实现的功能

# 添加防火墙规则
