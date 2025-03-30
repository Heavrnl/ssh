#!/bin/bash

# 定义 authorized_keys 文件路径
AUTHORIZED_KEYS="/root/.ssh/authorized_keys"

# 检查文件是否存在，如果不存在则创建
if [ ! -f "$AUTHORIZED_KEYS" ]; then
    echo "authorized_keys 文件不存在，正在创建..."
    mkdir -p /root/.ssh
    touch "$AUTHORIZED_KEYS"
    chmod 600 "$AUTHORIZED_KEYS"
fi

# 提示用户输入公钥
echo "请输入公钥文本："
read PUBLIC_KEY

# 将输入的公钥追加到文件最后一行
echo "$PUBLIC_KEY" >> "$AUTHORIZED_KEYS"

# 确认添加成功
echo "公钥已成功添加到 $AUTHORIZED_KEYS"
