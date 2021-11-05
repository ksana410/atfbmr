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
    if [ -f /etc/os-release ]; then
        # freedesktop.org and systemd
        . /etc/os-release
        MACHINE=$(uname -m)
        OS=$NAME
        VER=$VERSION_ID
    elif type lsb_release >/dev/null 2>&1; then
        # linuxbase.org
        MACHINE=$(uname -m)
        OS=$(lsb_release -si)
        VER=$(lsb_release -sr)
    elif [ -f /etc/lsb-release ]; then
        # For some versions of Debian/Ubuntu without lsb_release command
        . /etc/lsb-release
        MACHINE=$(uname -m)
        OS=$DISTRIB_ID
        VER=$DISTRIB_RELEASE
    elif [ -f /etc/debian_version ]; then
        # Older Debian/Ubuntu/etc.
        MACHINE=$(uname -m)
        OS=Debian
        VER=$(cat /etc/debian_version)
    elif [ -f /etc/SuSe-release ]; then
        # Older SuSE/etc.
        MACHINE=$(uname -m)
        OS=SuSE
        VER=$(cat /etc/SuSe-release)
    elif [ -f /etc/redhat-release ]; then
        # Older Red Hat, CentOS, etc.
        MACHINE=$(uname -m)
        OS=RedHat
        VER=$(cat /etc/redhat-release)
    else
        # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
        MACHINE=$(uname -m)
        OS=$(uname -s)
        VER=$(uname -r)
    fi
}

# 判断系统位数

# 生成配置文件

# 安装必要组件

# 下载组件

# 选择需要实现的功能

# 添加防火墙规则
