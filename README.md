# 一键设置ssh密钥登录+随机ssh端口

脚本基于Debian编写
一键运行
```bash
(command -v curl >/dev/null || (apt update && apt install -y curl)) && bash <(curl -Lso- https://raw.githubusercontent.com/Heavrnl/ssh/main/ssh.sh)
```

可自行设定ssh端口，留空则随机。
脚本运行后请复制私钥内容：
```
-----BEGIN OPENSSH PRIVATE KEY-----
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-----END OPENSSH PRIVATE KEY-----
```
并自行保存为文件，用于ssh登录使用

预览：

```
请输入希望使用的SSH端口号（直接回车则随机分配）: 
正在生成SSH密钥...
私钥内容如下:
-----BEGIN OPENSSH PRIVATE KEY-----
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-----END OPENSSH PRIVATE KEY-----

SSH端口已更改为 12788。
请检查防火墙确保端口 12788 已打开。
已启用基于密钥的身份验证，已禁用密码身份验证。
不要忘记保存私钥文件。


```


