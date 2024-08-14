#!/bin/bash

# 交互式选择

echo "1. 开启BBR并安装必要依赖"
echo "2. 安装Docker"
echo "3. 安装宝塔面板"
echo "4. 其他拥塞控制算法"
echo "5. 哪吒面板"
echo "6. s-ui面板"
echo "7. 流媒体检测"
echo "8. Swap"
echo "9. 内网穿透frp安装"
echo "10. 关闭ipv6"
echo "11. 三网测速"
echo "12. 修改命令提示符"
echo "13. 修改SSH配置并更改密码"
echo "14. 安装并连接Cloudflare WARP到40000端口"
echo "15. 安装traffmonetizer"
echo "16. 通过DNS-01 验证给域名申请ACME证书"
echo "17. 查看域名证书到期时间并手动选择是否强制更新证书"
echo "18. 更新本脚本"
echo "19. 可视化更改时区"
echo "0. 返回"


read -p "请输入选项编号：" choice

case $choice in
    1)
        # 开启BBR
        echo "开启BBR..."
        echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
        sysctl -p

        # 安装必要依赖
        echo "安装必要依赖..."
        apt update -y
        apt install sudo vim -y
        apt install vnstat -y
        apt install curl -y
        apt install bsdmainutils -y
        apt install unzip -y
        apt install net-tools -y
        apt install socat -y
        apt install cron -y
        curl https://get.acme.sh | sh
        source ~/.bashrc
        sed -i '/^alias kj='\''\/root\/scripts.sh'\''/d' ~/.bashrc && echo "alias kj='/root/scripts.sh'" >> ~/.bashrc && . ~/.bashrc
        echo "输入kj重新唤醒本脚本"

        ;;
    2)
        # 安装Docker
        echo "安装Docker..."
        wget -qO- get.docker.com | bash
        systemctl enable docker
        curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-Linux-x86_64 > /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
        echo "Docker版本"
        docker -v
        echo "Docker-compose版本"
        docker-compose --version
        echo -e "\n"
        ;;
    3)
        # 安装宝塔面板
        echo "安装宝塔面板..."
        URL=https://www.aapanel.com/script/install_7.0_en.sh && if [ -f /usr/bin/curl ];then curl -ksSO "$URL" ;else wget --no-check-certificate -O install_7.0_en.sh "$URL";fi;bash install_7.0_en.sh aapanel
        apt remove ufw -y
        apt autoremove ufw -y
        ;;
    4)
        # 查看可用的拥塞控制算法
        echo "可用的拥塞控制算法："
        wget -O tcpx.sh "https://git.io/JYxKU" && chmod +x tcpx.sh && ./tcpx.sh
        ;;
    5)
        # 哪吒面板
        echo "哪吒面板安装中..."
        curl -L https://raw.githubusercontent.com/naiba/nezha/master/script/install.sh -o nezha.sh && chmod +x nezha.sh && sudo ./nezha.sh
        ;;
    6)
        # x-ui面板
        echo "s-ui面板..."
        bash <(curl -Ls https://raw.githubusercontent.com/alireza0/s-ui/master/install.sh)
        ;;
    7)
        # 流媒体检测
        echo "流媒体检测中..."
        bash <(curl -L -s media.ispvps.com) -M 4
        ;;
    8)
        # Swap
        echo "Swap安装中..."
        wget https://raw.githubusercontent.com/zhucaidan/swap.sh/main/swap.sh && bash swap.sh
        ;;
    9)
        # frp安装
        echo "frp安装中..."
        wget https://raw.githubusercontent.com/mvscode/frps-onekey/master/install-frps.sh -O ./install-frps.sh
        chmod 700 ./install-frps.sh
        ./install-frps.sh install
        ;;
    10)
        # 关闭ipv6
        echo "关闭ipv6中..."
        echo "net.ipv6.conf.all.disable_ipv6=1" >> /etc/sysctl.conf
        echo "net.ipv6.conf.default.disable_ipv6=1" >> /etc/sysctl.conf
        echo "net.ipv6.conf.lo.disable_ipv6=1" >> /etc/sysctl.conf

        sudo touch /etc/systemd/system/sysctl-p.service

        echo "[Unit]" >> /etc/systemd/system/sysctl-p.service
        echo "Description=Apply sysctl settings at boot" >> /etc/systemd/system/sysctl-p.service
        echo "DefaultDependencies=no" >> /etc/systemd/system/sysctl-p.service
        echo "Before=local-fs.target" >> /etc/systemd/system/sysctl-p.service
        echo "[Service]" >> /etc/systemd/system/sysctl-p.service
        echo "Type=oneshot" >> /etc/systemd/system/sysctl-p.service
        echo "ExecStart=/sbin/sysctl -p" >> /etc/systemd/system/sysctl-p.service
        echo "[Install]" >> /etc/systemd/system/sysctl-p.service
        echo "WantedBy=sysinit.target" >> /etc/systemd/system/sysctl-p.service
        sudo systemctl daemon-reload
        sudo systemctl enable sysctl-p.service
        sudo systemctl start sysctl-p.service
        ;;
    11)
        # 三网测速
        echo "三网测速中..."
        bash <(curl -Lso- https://bench.im/hyperspeed)
        ;;
    12)
        # 修改命令提示符
        read -p "请输入你想要的名称：" newname
        echo "修改命令提示符为 root@$newname..."

        # 修改 /etc/bash.bashrc
        if grep -q "PS1='\\\$debian_chroot" /etc/bash.bashrc; then
            sed -i "s/PS1='\\\$debian_chroot.*'/PS1='${debian_chroot:+(\$debian_chroot)}\u@$newname:\w# '/" /etc/bash.bashrc
        else
            echo "PS1='${debian_chroot:+(\$debian_chroot)}\u@$newname:\w# '" >> /etc/bash.bashrc
        fi

        # 修改 /root/.bashrc
        if grep -q "PS1='\\\$debian_chroot" /root/.bashrc; then
            sed -i "s/PS1='\\\$debian_chroot.*'/PS1='${debian_chroot:+(\$debian_chroot)}\u@$newname:\w# '/" /root/.bashrc
        else
            echo "PS1='${debian_chroot:+(\$debian_chroot)}\u@$newname:\w# '" >> /root/.bashrc
        fi

        source /etc/bash.bashrc
        source /root/.bashrc

        echo "命令提示符已更改为 root@$newname"
        ;;
    13)
        # 修改SSH配置并更改密码
        echo "修改SSH配置文件..."
        sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
        sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
        sed -i 's/^#PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
        sed -i 's/^PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
        sed -i 's/^#KbdInteractiveAuthentication.*/KbdInteractiveAuthentication yes/' /etc/ssh/sshd_config
        sed -i 's/^KbdInteractiveAuthentication.*/KbdInteractiveAuthentication yes/' /etc/ssh/sshd_config
        sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
        sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
        systemctl restart sshd
        echo "SSH配置已修改。"

        echo "请设置新的SSH密码："
        passwd
        ;;
    14)
        # 安装并连接Cloudflare WARP
        echo "安装并连接Cloudflare WARP..."
        sudo apt update
        sudo apt install gnupg -y
        curl https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list
        apt update
        apt install cloudflare-warp -y
        warp-cli register
        warp-cli set-mode proxy
        warp-cli connect
        sudo systemctl restart warp-svc
        curl ifconfig.me --proxy socks5://127.0.0.1:40000
        ;;
    15)
        echo "安装必要依赖..."
        apt update -y
        apt install sudo vim -y
        apt install vnstat -y
        apt install curl -y
        apt install bsdmainutils -y
        apt install unzip -y
        apt install net-tools -y
        apt install socat -y
        # 安装Docker
        echo "安装Docker..."
        wget -qO- get.docker.com | bash
        systemctl enable docker
        curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-Linux-x86_64 > /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
        echo "Docker版本"
        docker -v
        echo "Docker-compose版本"
        docker-compose --version
        echo -e "\n"
        docker run -d --restart=always -e EARNFM_TOKEN="4bff00f2-eef3-4484-b49c-f2c0e3ae4ddf" --name earnfm-client earnfm/earnfm-client:latest
        docker run --name repocket -e RP_EMAIL=enochkingsley83@gmail.com -e RP_API_KEY=5rg1EilcRORr4ZqV77OSTtqh0GV2 -d --restart=always repocket/repocket
        docker run -i --name tm --restart=always traffmonetizer/cli_v2 start accept --token Jq4D2YD05tkorrjfCIgn7NNsUwjMuoiykjJBQ7EbMKY=
        ;;
    16)
        curl -L https://raw.githubusercontent.com/EnochKingsley83/Rule/main/registercert.sh -o registercert.sh && chmod +x registercert.sh && sudo ./registercert.sh
        curl -L https://raw.githubusercontent.com/EnochKingsley83/Rule/main/updatecert.sh -o updatecert.sh && chmod +x updatecert.sh
        (crontab -l 2>/dev/null | grep -v '0 0 * * * /root/updatecert.sh'; echo '0 0 * * * /root/updatecert.sh') | crontab -
        sudo systemctl restart cron
        ;;
    17)
    echo "选择操作"
    echo "1.表示查看证书到期时间"
    echo "2.表示强制更新所有证书"
    echo
    read -p "请输入您的选择 (1 或 2): " choice
     
    case $choice in
        1)
            echo "下载并运行查看证书到期时间的脚本..."
            curl -L https://raw.githubusercontent.com/EnochKingsley83/Rule/main/showdate.sh -o showdate.sh
            chmod +x showdate.sh
            ./showdate.sh
            echo
            ;;
        2)
            echo "下载并运行强制更新证书的脚本..."
            curl -L https://raw.githubusercontent.com/EnochKingsley83/Rule/main/updatecert.sh -o updatecert.sh
            chmod +x updatecert.sh
            ./updatecert.sh
            echo
            ;;
        *)
            echo "无效的选择。请输入 1 或 2。"
            ;;
    esac
    echo
    ;;
    18)
        curl -L https://raw.githubusercontent.com/EnochKingsley83/Rule/main/scripts.sh -o scripts.sh && chmod +x scripts.sh
        ;;
    19)
        sudo dpkg-reconfigure tzdata
        ;;
    0)
        # 返回
        echo "退出脚本..."
        exit
        ;;
    *)
        echo "无效选项"
        ;;
esac

echo "脚本执行完毕，重新运行中..."
sleep 2
echo
echo
./scripts.sh
