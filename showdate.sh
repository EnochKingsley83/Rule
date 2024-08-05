#!/bin/bash

# 切换到存放证书的目录
certPath="/root/cert"
cd "$certPath" || { echo "无法访问目录 $certPath"; exit 1; }

# 临时文件
tempFile=$(mktemp)

# 打印表头
echo -e "域名\t申请时间\t到期时间" > "$tempFile"

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
        
        # 打印结果到临时文件
        echo -e "$domain\t$issuedDate\t$expiryDate" >> "$tempFile"
    else
        # 证书文件缺失，打印相应的消息到临时文件
        echo -e "$domain\t证书文件缺失\t证书文件缺失" >> "$tempFile"
    fi
done

# 打印分隔线和格式化输出
echo "---------------------------------------------------------------"
column -t -s $'\t' "$tempFile"
echo "---------------------------------------------------------------"

# 删除临时文件
rm "$tempFile"
