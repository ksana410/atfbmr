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
if [[ $(di -u) != "0" ]]; then
    printf "\e[42m\e[31mError: You must be root to run this install script.\e[0m\n"
    exit 1
fi

# if [ $(whoami) != 'root' ];then
#    echo `date "+%Y/%m/%d %H:%M:%S> "` "必须用 root 账户执行此脚本！"
#    exit
#fi
   
# 检测Linux发行版

check_sys(){
    local checkType=$1
    local value=$2

    local release=''
    local systemPackage=''

    if [[ -f /etc/redhat-release ]]; then
        release="centos"
        systemPackage="yum"
    elif grep -Eqi "debian|raspbian" /etc/issue; then
        release="debian"
        systemPackage="apt"
    elif grep -Eqi "ubuntu" /etc/issue; then
        release="ubuntu"
        systemPackage="apt"
    elif grep -Eqi "centos|red hat|redhat" /etc/issue; then
        release="centos"
        systemPackage="yum"
    elif grep -Eqi "debian|raspbian" /proc/version; then
        release="debian"
        systemPackage="apt"
    elif grep -Eqi "ubuntu" /proc/version; then
        release="ubuntu"
        systemPackage="apt"
    elif grep -Eqi "centos|red hat|redhat" /proc/version; then
        release="centos"
        systemPackage="yum"
    fi

    if [[ "${checkType}" == "sysRelease" ]]; then
        if [ "${value}" == "${release}" ]; then
            return 0
        else
            return 1
        fi
    elif [[ "${checkType}" == "packageManager" ]]; then
        if [ "${value}" == "${systemPackage}" ]; then
            return 0
        else
            return 1
        fi
    fi
}

# 判断系统位数
