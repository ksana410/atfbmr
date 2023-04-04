#!/usr/bin/env bash

# This is a shell script for configuare iptables rule
# It can build a Linux router with iptables and give you a router can over the wall

# 常见的 C 类地址
ipv4_privaty_ipadds=(
    0.0.0.0/8
    10.0.0.0/8
    100.64.0.0/10
    127.0.0.0/8
    169.254.0.0/16
    172.16.0.0/12
    192.168.0.0/16
    224.0.0.0/4
    240.0.0.0/4    
)

# 常用的 DNS 地址
ipv4_dns_ipadds=(
    8.8.8.8
    8.8.4.4
)
