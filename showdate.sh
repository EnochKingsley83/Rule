#!/bin/bash

# 切换到存放证书的目录
certPath="/root/cert"
cd "$certPath" || { echo "无法访问目录 $certPath"; exit 1; }

# 打印表头和分隔线
printf "%-30s | %-30s | %-30s\n" "域名" "申请时间" "到期时间"
printf "%s\n" "--------------------------------------------------------------"

# 遍历每个子目录
for dir in */; do
    # 移除结尾的斜杠
    domain="${dir%/}"
    certFile="${certPath}/${domain}/fullchain.cer"
    
    # 检查证书文件是否存在
    if [[ -f "$certFile" ]]; then
        # 使用 openssl 提取申请时间和到期时间
        issuedDate=$(openssl x509 -in "$certFile" -noout -startdate | sed 's/notBefore=//')
        expiryDate=$(openssl x509 -in "$certFile" -noout -enddate | sed 's/notAfter=//')
        
        # 打印结果
        printf "%-30s | %-30s | %-30s\n" "$domain" "$issuedDate" "$expiryDate"
    else
        printf "%-30s | %-30s | %-30s\n" "$domain" "证书文件缺失" "证书文件缺失"
    fi
done
