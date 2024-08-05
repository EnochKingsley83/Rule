#!/bin/bash

# 遍历所有域名文件夹并进行证书更新
for domainDir in /root/cert/*; do
    if [ -d "$domainDir" ]; then
        domain=$(basename "$domainDir")
        echo "正在检查和更新域名：$domain"

        # 使用 acme.sh 检查证书是否需要更新并强制更新
        ~/.acme.sh/acme.sh --renew -d "$domain" -d "*.$domain" --force

        if [ $? -ne 0 ]; then
            echo "证书更新失败，请检查错误日志。"
            exit 1
        else
            echo "证书更新成功。"
            echo "证书保存路径: $domainDir"
        fi
    fi
done

# 更新 acme.sh 脚本
echo "正在更新 acme.sh 脚本..."
~/.acme.sh/acme.sh --upgrade --auto-upgrade
if [ $? -ne 0 ]; then
    echo "acme.sh 脚本自动更新失败，请检查错误日志。"
else
    echo "acme.sh 脚本已成功更新。"
fi

echo "脚本执行完毕。"
