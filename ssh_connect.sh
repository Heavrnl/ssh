#!/bin/bash

# 显示公钥内容
echo "以下是您的公钥内容："
cat /root/.ssh/id_rsa.pub
echo ""

# 提示用户输入 IP 地址和 SSH 端口
read -p "请输入目标 IP 地址: " IP
read -p "请输入 SSH 端口: " PORT

# 执行 SSH 连接，自动接受主机密钥并立即退出
ssh -o StrictHostKeyChecking=no -p $PORT root@$IP -t 'exit'
