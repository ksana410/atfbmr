#!/usr/bin/env bash

# This script is used to build the Linux NAT system.
# It is used to build the system for the following linux distributions:
#  - CentOS
#  - Ubuntu
#  - Debian
#  - Fedora
#  - Alpine
#  - Rocky
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

export LANG="en_US.UTF-8"

# Check if the user is root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root"
    exit 1
fi

# Set color code
# 设置前景tput setaf <color_code>
# 设置背景tput setab <color_code>
# 0：黑色
# 1：蓝色
# 2：绿色
# 3：青色
# 4：红色
# 5：洋红色
# 6：黄色
# 7：白色
# 除了使用tput方法，还可以使用echo -e "\033[31m ddd \033[0m"这样的方式执行
# 编码 颜色/动作
# 0 重新设置属性到缺省设置
# 1 设置粗体
# 2 设置一半亮度（模拟彩色显示器的颜色）
# 4 设置下划线（模拟彩色显示器的颜色）
# 5 设置闪烁
# 7 设置反向图象
# 22 设置一般密度
# 24 关闭下划线
# 25 关闭闪烁
# 27 关闭反向图象
# 30 设置黑色前景
# 31 设置红色前景
# 32 设置绿色前景
# 33 设置棕色前景
# 34 设置蓝色前景
# 35 设置紫色前景
# 36 设置青色前景
# 37 设置白色前景
# 38 在缺省的前景颜色上设置下划线
# 39 在缺省的前景颜色上关闭下划线
# 40 设置黑色背景
# 41 设置红色背景
# 42 设置绿色背景
# 43 设置棕色背景
# 44 设置蓝色背景
# 45 设置紫色背景
# 46 设置青色背景
# 47 设置白色背景
# 49 设置缺省黑色背景

red=$(tput setaf 1)
green=$(tput setaf 2)
aoi=$(tput setaf 6)
reset=$(tput sgr0)

# 输出字体颜色设置
colorEcho() {
    case $1 in
        red)
            echo -e "${red}${@:2}${reset}"
            ;;
        green)
            echo -e "${green}${@:2}${reset}"
            ;;
        aoi)
            echo -e "${aoi}${@:2}${reset}"
            ;;
        *)
            echo ${@:2}
            ;;
    esac
}

# Check if the system is supported and what is the distribution name
sysCheck() {
    colorEcho green "Checking system..."
    if [[ type -P apt ]]; then
        if grep </proc/version -q -i "ubuntu"; then
            echo "${green}This is Ubuntu${reset}"
            OS='ubuntu'
        elif grep </proc/version -q -i "debian"; then
            echo "${green}This is Debian${reset}"
            OS='debian'
        fi
        VER=$(lsb_release -a | grep -i "release" | awk '{print $2}' | cut -d '.' -f1)
        installCmd='apt -y install'
        updateCmd='apt update'
        upgradeCmd='apt -y upgrade'
        removeCmd='apt -y autoremove'
    elif [[ type -P dnf ]]; then
        if grep </proc/version -q -i "fedora"; then
            echo "${green}This is Fedora${reset}"
            OS='fedora'
        elif grep </proc/version -q -i "rocky"; then
            echo "${green}This is Rocky${reset}"
            OS='rocky'
        elif grep </proc/version -q -i "centos"; then
            echo "${green}This is CentOS${reset}"
            OS='centos'
        fi
        VER=$(cat /etc/redhat-release | grep -i "release" | awk '{print $4}' | cut -d '.' -f1)
        installCmd='dnf -y install'
        updateCmd='dnf -y update'
        upgradeCmd='dnf -y upgrade'
        removeCmd='dnf -y remove'
    elif [[ type -P yum ]]; then
        if grep </proc/version -q -i "fedora"; then
            echo "${green}This is Fedora${reset}"
            OS='fedora'
        elif grep </proc/version -q -i "centos"; then
            echo "${green}This is CentOS${reset}"
            OS='centos'
        fi
        VER=$(cat /etc/redhat-release | grep -i "release" | awk '{print $4}' | cut -d '.' -f1)
        installCmd='yum -y install'
        updateCmd='yum -y update'
        upgradeCmd='yum -y upgrade'
        removeCmd='yum -y remove'
    elif [[ type -P apk ]]; then
        if grep </proc/version -q -i "alpine"; then
            echo "${green}This is Alpine${reset}"
            OS='alpine'
        fi
        VER=$(cat /etc/alpine-release | cut -d '.' -f1)
        installCmd='apk -q add'
        updateCmd='apk update'
        upgradeCmd='apk upgrade'
        removeCmd='apk del'
    else
        echo "${red}This system is not supported.${reset}"
        exit 1
    fi

    if [[ -z $OS ]] || [[ -z $VER ]]; then
        echo "${red}This system is not supported.${reset}"
        exit 1
    fi
}

# 判断系统使用的是systemd还是init
initCheck() {
    if [[ $OS == 'ubuntu' ]] || [[ $OS == 'debian' ]]; then
        if [[ $(systemctl is-active systemd) == 'active' ]]; then
            echo "${green}This system uses systemd${reset}"
            INIT='systemd'
        else
            echo "${green}This system uses init${reset}"
            INIT='init'
        fi
    elif [[ $OS == 'fedora' ]] || [[ $OS == 'centos' ]] || [[ $OS == 'rocky' ]]; then
        if [[ $(systemctl is-active systemd) == 'active' ]]; then
            echo "${green}This system uses systemd${reset}"
            INIT='systemd'
        else
            echo "${green}This system uses init${reset}"
            INIT='init'
        fi
    elif [[ $OS == 'alpine' ]]; then
        INIT='init'
    fi
    if [[ INIT == 'init' ]]; then
        serviceCtl='service'
    else
        serviceCtl='systemctl'
    fi
}

# 初始化全局变量
initVar() {
    # Configuration Directory
    CONFIG_DIR='/etc/natsys'
    # 网卡相关配置
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
    # 系统相关配置
    SYS_TIMEZONE='Asia/Shanghai'
    SYS_HOSTNAME=''
    # 防火墙相关配置
    FIREWALL_TYPE='iptables'
    FIREWALL_STATUS='off'
    FIREWALL_PORT_STATUS='off'
    FIREWALL_PORT_LIST=''
    FIREWALL_IP_STATUS='off'
    # 透明代理相关配置
    PROXY_TYPE='socks5'
    TRANSPROXY_INSTALLED=0
    TRANSPROXY_NEED_INSTALL=0
    # DNS相关配置
    DNS_TYPE='dnsmasq'
    DNS_CRYPT_TYPE='none'
    DNS_REMOTE_SERVER=''
    DNS_LOCAL_PORT=''
    DNS_REMOTE_PORT=''
}


# Check the number and naming of system NICs
netCheck() {
    # Get the number of NICs
    NIC_NUM=$(ip link | grep -c ":")
    # Get the names of NICs
    NIC_NAME=$(ip link | grep -o ": [a-zA-Z0-9]*" | cut -d ":" -f 2)
    # Check if the number of NICs is 2
    if [ $NIC_NUM -ne 2 ]; then
        echo "The number of NICs is not 2"
        exit 1
    fi
    # Check if the names of NICs are eth0 and eth1
    if [ "$NIC_NAME" != "eth0" ] && [ "$NIC_NAME" != "eth1" ]; then
        echo "The names of NICs are not eth0 and eth1"
        exit 1
    fi
}

# config selinux if it is enabled
closeSElinux() {
    if [[ $OS == "centos" ]] || [[ $OS == "fedora" ]] || [[ $OS == "rocky" ]]; then
        if [[ $(getenforce) == "Enforcing" ]]; then
            colorEcho yellow "SElinux is enabled, configuring..."
            sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
            setenforce 0
        fi
    else
        colorEcho green "SElinux is not supported, skipping..."
    fi
}

# 安装所需要的环境依赖
# DHCP: dnsmasq
# DNS: dnsmasq || dnscrypt-proxy || v2ray
# transproxy: v2ray/xray || clash
# firewall: firewalld || iptables || nftables
# ipv6: ip6tables || ebtables
# vlan: iproute2
# vpn: wireguard


# Install Linux Dependent
installDependent() {

}

# Update Project
updateProject(){
    if [[ -f $CONFIG_DIR/config.json]]; then
        if [[ $FORCE -eq 1 ]]; then
            echo "Force update"
            rm -rf $CONFIG_DIR/config.json
}



# Config dnsmasq with v2ray or dnscrypt-proxy for dns and dhcp

# Build a DHCP system with dnsmasq
dhcpConfig() {
    echo "Building a DHCP system with dnsmasq"
    if [ -f /etc/dnsmasq.conf ]; then
        if [ -f /etc/dnsmasq.conf.d/dhcp.conf ]; then
            :
        else
            touch /etc/dnsmasq.conf.d/dhcp.conf
            cat > /etc/dnsmasq.conf.d/dhcp.conf << EOF
interface=eth0
EOF
        fi
    else
        echo "No dnsmasq config file found"

# Sysctl config
# net.ipv4.ip_forward = 1
# *net.ipv4.tcp_fastopen = 3
# if linux kernel version is 4.15+, add the following line to /etc/sysctl.conf
# net.ipv4.tcp_congestion_control = bbr
# net.core.default_qdisc = fq
sysctlConfig(){
    echo "Configuring sysctl"
    if [ -f /etc/sysctl.conf ]; then
        if grep -q "net.ipv4.ip_forward" /etc/sysctl.conf; then
            :
        else
            echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
        fi
        if grep -q "net.ipv4.tcp_fastopen" /etc/sysctl.conf; then
            :
        else
            echo "net.ipv4.tcp_fastopen = 3" >> /etc/sysctl.conf
        fi
        if $KERNEL_VERSION >= 4.15; then
            if grep -q "net.ipv4.tcp_congestion_control" /etc/sysctl.conf; then
                :
            else
                echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.conf
            fi
        fi
        if grep -q "net.core.default_qdisc" /etc/sysctl.conf; then
            :
        else
            echo "net.core.default_qdisc = fq" >> /etc/sysctl.conf
        fi
    else
        echo "No sysctl config file found"
        echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_fastopen = 3" >> /etc/sysctl.conf
        if $KERNEL_VERSION >= 4.15; then
            echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.conf
        fi
        echo "net.core.default_qdisc = fq" >> /etc/sysctl.conf
    fi
}

# 网卡配置及模式选择
# 配置网卡，是否需要单臂模式，如果使用单臂模式，则必须启用vlan，否则无法使用，此时须做出提示，要求网络中存在支持vlan的交换机
natSel() {
    colorEcho green "Configure Network"
    # Check if the NIC is configured
    if [[ -f ${CONFIG_DIR/netconfig} ]]; then
        colorEcho green "Network is configured"
        return
    elif [[ $OS == "centos" ]] || [[ $OS == "fedora" ]] || [[ $OS == "rocky" ]]; then
        

}



# 主控制菜单
mainMenu() {
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