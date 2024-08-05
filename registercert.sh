#!/bin/bash

# 安装 acme.sh
if [ ! -d "$HOME/.acme.sh" ]; then
    echo "安装 acme.sh..."
    curl https://get.acme.sh | sh
    source ~/.bashrc
fi

# 提示用户输入邮箱、API 密钥和域名
read -p "请输入您的邮箱: " email
read -p "请输入您的 Cloudflare API 密钥: " api_key
read -p "请输入您的域名: " domain

# 设置 Cloudflare API 的环境变量
export CF_Email="$email"
export CF_Key="$api_key"

# 更新 bashrc 文件以持久化这些环境变量
echo "export CF_Email=\"$email\"" >> ~/.bashrc
echo "export CF_Key=\"$api_key\"" >> ~/.bashrc
source ~/.bashrc

# 注册 acme.sh 账户
~/.acme.sh/acme.sh --register-account -m "$email"

# 基础证书保存目录
base_dir="/root/cert"
domain_dir="${base_dir}/${domain}"

# 创建域名目录
mkdir -p "$domain_dir"

# 申请证书
~/.acme.sh/acme.sh --issue --dns dns_cf -d "$domain"

# 安装证书到指定目录
~/.acme.sh/acme.sh --install-cert -d "$domain" \
    --cert-file "${domain_dir}/${domain}.cer" \
    --key-file "${domain_dir}/${domain}.key" \
    --fullchain-file "${domain_dir}/fullchain.cer" \
    --ca-file "${domain_dir}/ca.cer"

echo "证书已成功申请并安装到 ${domain_dir}"
