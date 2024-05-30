#!/bin/bash

# 备份现有的SSH配置
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# 提示用户输入端口号
read -p "请输入希望使用的SSH端口号（直接回车则随机分配）: " port_input

# 如果没有输入端口号，则生成一个随机端口号
if [ -z "$port_input" ]; then
    port=$(shuf -i 20000-60000 -n 1)
else
    port=$port_input
fi

# 如果SSH密钥不存在，则生成SSH密钥
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "正在生成SSH密钥..."
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -q -N ""
fi

# 将SSH密钥添加到授权密钥中
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh

# 更新SSH配置
sudo sed -i 's/^#\?\(PubkeyAuthentication\s*\).*$/\1yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?\(PasswordAuthentication\s*\).*$/\1no/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?\(ChallengeResponseAuthentication\s*\).*$/\1no/' /etc/ssh/sshd_config
sudo sed -i "s/^#\?\\(Port\\s*\\).*$/\\1$port/" /etc/ssh/sshd_config

# 重启SSH服务
sudo systemctl restart sshd

# 检查SSH服务是否正在运行
if systemctl is-active --quiet sshd; then
   echo -e "SSH端口已更改为 $port。\n请检查防火墙确保端口 $port 已打开。\n已启用基于密钥的身份验证，已禁用密码身份验证。\n不要忘记保存私钥文件。"
else
# SSH服务启动失败，恢复原始配置并显示错误消息
   echo "错误：SSH服务启动失败。正在恢复原始配置..."
   sudo cp /etc/ssh/sshd_config.bak /etc/ssh/sshd_config
   sudo systemctl restart sshd
   echo "SSH服务已恢复到原始配置。"
   exit 1
fi

# 删除SSH配置的备份（可选）
# sudo rm /etc/ssh/sshd_config.bak