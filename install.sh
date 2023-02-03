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
# This script is used to build the Linux NAT system.
# It is used to build the system for the following linux distributions:
#  - Debian
#  - Alpine
# It uses interactive mode to set up the network, transparent proxy and some other features.
# 执行流程——识别系统信息，包括网口数量，架构，操作系统版本——使用交互模式对系统进行配置，指定网口类型，是否需要使用单臂模式，是否开启vlan，内网网段，上网模式，是否需要开启透明
# 代理——
# 交互方式询问用户如何进行下一步操作
# 安装模式：普通路由模式，旁路模式，单臂路由模式
# 是否需要启用VLAN：默认不启用，单臂模式则必须启动
# 按需选择不同网卡的作用，WAN口，LAN口，如果用户通过SSH登陆，则优先将所连接网卡设置成LAN口
# 是否需要启用IPv6：默认不启用，如果需要，则需要安装ip6tables或者ebtables
# 是否需要启用VPN：默认不启用，如果需要，则需要安装wireguard
# 防火墙模式选择：优先基于系统所安装版本进行设置，当然也可以使用用户选择进行操作，现在支持iptables,firewalld,nftables
# 不同发行版的防火墙启动方式不同，如果是debian系，则需要手动安装对应的启动服务iptables-persistent
# 如果是centos系，则只需要开启firewalld服务即可
# 询问是否需要开启科学上网功能，现有支持v2ray和clash作为透明代理使用，使用个人节点还是订阅，如果需要订阅的话暂时只能使用clash进行操作
# 所有配置结束之后进行最后的安装，依赖安装，之后进行设置，防火墙设置，科学上网设置，VPN设置，最后进行服务启动

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
if [[ $(id -u) -ne "0" ]]; then
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

# 安装前检测
installPrecheck(){
    echo "${Yellow}################################${Reset}"
    echo "${Yellow}#                              #${Reset}"
    echo "${Yellow}# Pre-installation testing     #${Reset}"
    echo "${Yellow}#                              #${Reset}"
    echo "${Yellow}################################${Reset}"

    sleep 3
    isPort=`ss -tunlp | grep -Eq ":80 |:443"`
    if [[ "${isPort}" != '' ]]; then
        echo "${Red} Port is occupied! ${Reset}"
        exit 1
    fi
}

# 安装ShadowTls
install_shadowTls() {  
}

# 安装sing-box
install_singBox() {
}

# 安装verysimple
install_verysimple() {
}

# 环境变量配置

# 生成配置文件

# 安装必要组件
install_pack() {
    PKM install git
}

# 下载组件

# 选择需要实现的功能

# 添加防火墙规则

# 主控制菜单
main_Menu() {
    colorEcho green "1. 配置NAT"
    colorEcho green "2. 开启透明代理"
    colorEcho green "3. 卸载配置"
    colorEcho green "4. 退出"
    read -p "请输入选项：" installType
    case $installType in
        1)
            colorEcho green "Building NAT system for Linux"
            natConfig
            ;;
        2)
            transproxyConfig
            ;;
        3)
            uninstall
            ;;
        4)  
            colorEcho yellow "Bye!"
            exit 0
            ;;
        *)
            colorEcho red "选项错误，请重新输入"
            mainMenu
            ;;
    esac
}
