#!/bin/bash

# 交互式选择
echo "请选择要执行的操作："
echo "1. 开启BBR并安装必要依赖"
echo "2. 安装Docker"
echo "3. 添加Swap"
echo "4. 其他拥塞控制算法"
echo "5. 哪吒面板"
echo "6. x-ui面板"
echo "7. 流媒体检测"
echo "8. Hysteria2一键脚本"
echo "9. 内网穿透frp安装"
echo "10. 关闭ipv6"
echo "11. 三网测速"
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
	apt install unzip -y
	apt install net-tools -y
	apt install socat -y
        apt install cron -y
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
        # 添加Swap
        echo "添加Swap..."
        bash <(wget --no-check-certificate -qO- https://cdn.jsdelivr.net/gh/Moexin/Shell@master/Swap.sh)
        ;;
    4)
        # 查看可用的拥塞控制算法
        echo "可用的拥塞控制算法："
        wget -O tcpx.sh "https://git.io/JYxKU" && chmod +x tcpx.sh && ./tcpx.sh
        ;;
    5)
        # 哪吒面板
        echo "哪吒面板安装中..."
        wget -O install.sh https://raw.gitmirror.com/naiba/nezha/master/script/install.sh && bash install.sh
        ;;
    6)
        # x-ui面板
        echo "x-ui面板..."
        bash <(curl -Ls https://raw.githubusercontent.com/FranzKafkaYu/x-ui/master/install.sh)
        ;;
    7)
        # 流媒体检测
        echo "流媒体检测中..."
        bash <(curl -L -s media.ispvps.com) -M 4
        ;;
    8)
        # Hysteria2
        echo "Hysteria2安装中..."
        wget -N --no-check-certificate https://raw.githubusercontent.com/flame1ce/hysteria2-install/main/hysteria2-install-main/hy2/hysteria.sh && bash hysteria.sh
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
        echo "frp安装中..."
        bash <(curl -Lso- https://bench.im/hyperspeed)
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
./"$0"
