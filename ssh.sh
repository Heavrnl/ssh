#!/bin/bash

# 确保具有 sudo 权限
if ! command -v sudo &>/dev/null; then
    echo "未找到 sudo 命令，正在尝试安装..."
    su -c "apt-get update && apt-get install -y sudo"
    if ! command -v sudo &>/dev/null; then
        echo "错误：无法安装 sudo，请手动安装后重试。"
        exit 1
    fi
fi

# 确保 shuf 可用
if ! command -v shuf &>/dev/null; then
    echo "未找到 shuf 命令，正在尝试安装 coreutils..."
    sudo apt-get update && sudo apt-get install -y coreutils
    if ! command -v shuf &>/dev/null; then
        echo "错误：无法安装 shuf，请手动安装 coreutils 并重试。"
        exit 1
    fi
fi

# 备份 SSH 配置
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak



# 提示用户输入端口号
read -p "请输入希望使用的 SSH 端口号（直接回车则随机分配）: " port_input

# 端口号验证函数
is_port_free() {
    local port=$1
    if ss -tuln | grep -q ":$port "; then
        return 1 # 端口被占用
    else
        return 0 # 端口可用
    fi
}

# 选择端口号
if [ -z "$port_input" ]; then
    # 生成随机端口，确保未被占用
    for _ in {1..10}; do
        port=$(shuf -i 20000-60000 -n 1)
        if is_port_free "$port"; then
            break
        fi
    done

    # 如果尝试10次仍未找到可用端口，退出
    if ! is_port_free "$port"; then
        echo "错误：无法找到可用的随机端口，请手动输入端口号。"
        exit 1
    fi
else
    if [[ ! "$port_input" =~ ^[0-9]+$ ]] || [ "$port_input" -lt 1 ] || [ "$port_input" -gt 65535 ]; then
        echo "错误：无效端口号 '$port_input'，请输入 1-65535 之间的数字。"
        exit 1
    fi

    # 用户输入的端口也需要检查是否被占用
    if ! is_port_free "$port_input"; then
        echo "错误：端口 $port_input 已被占用，请选择其他端口。"
        exit 1
    fi

    port=$port_input
fi

# 确保 SSH 密钥存在
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "正在生成 SSH 密钥..."
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -q -N ""
fi

# 避免重复添加 SSH 公钥
if ! grep -qF "$(cat ~/.ssh/id_rsa.pub)" ~/.ssh/authorized_keys; then
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
fi

chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh

# 更新 SSH 配置
sudo sed -i 's/^#\?\(PubkeyAuthentication\s*\).*$/\1yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?\(PasswordAuthentication\s*\).*$/\1no/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?\(ChallengeResponseAuthentication\s*\).*$/\1no/' /etc/ssh/sshd_config
sudo sed -i "s/^#\?Port .*/Port $port/" /etc/ssh/sshd_config
sudo rm -rf /etc/ssh/sshd_config.d/
# 重启 SSH 服务
sudo systemctl restart sshd

# 检查 SSH 是否成功启动
if systemctl is-active --quiet sshd; then
    printf "私钥内容如下，请妥善保存：\n\n"
    stdbuf -oL cat ~/.ssh/id_rsa
    printf "\n"
    echo "SSH 端口已更改为 $port。"
    echo "请检查防火墙确保端口 $port 已打开。"
    echo "已启用基于密钥的身份验证，已禁用密码身份验证。"
    echo "不要忘记保存私钥文件。"
else
    echo "错误：SSH 服务启动失败，正在恢复原始配置..."
    sudo cp /etc/ssh/sshd_config.bak /etc/ssh/sshd_config
    sudo systemctl restart sshd
    echo "SSH 服务已恢复到原始配置。"
    echo "请检查 /var/log/auth.log 或运行 journalctl -xe 以获取详细错误信息。"
    exit 1
fi

# 删除 SSH 配置备份（可选）
# sudo rm /etc/ssh/sshd_config.bak
