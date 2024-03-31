#!/bin/bash

# 交互式选择
echo "请选择要执行的操作："
echo "1. 开启BBR并安装必要依赖"
echo "2. 安装Docker"
echo "3. 添加Swap"
echo "4. 其他拥塞控制算法"
echo "5. 哪吒面板"
echo "6. 3x-ui面板"
echo "7. 流媒体检测"
echo "8. Hysteria2一键脚本"
echo "9. 内网穿透frp安装"
echo "10. 关闭ipv6"
echo "11. 一键安装订阅转换前后端(会自动安装aapanel)"
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
        curl -L https://raw.githubusercontent.com/naiba/nezha/master/script/install.sh  -o nezha.sh && chmod +x nezha.sh && sudo ./nezha.sh
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
        # 一键安装订阅转换前后端
        echo "安装订阅转换前后端中..."
        echo "安装node 16和yarn1.22.19..."
        npm install -g cnpm --registry=https://registry.npmmirror.com
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
        export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
        nvm install 16
        nvm use 16
        curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
        echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
        sudo apt-get update
        sudo apt-get install -y yarn
        echo "node版本为"
        node -v
        echo "yarn版本为"
        yarn --version

        #下载并安装 Sub-Web
        git clone https://github.com/CareyWang/sub-web.git
        cd sub-web
        yarn install
        yarn build
        cd /root
        wget https://github.com/MetaCubeX/subconverter/releases/download/Alpha/subconverter_linux64.tar.gz
        tar -zxvf subconverter_linux64.tar.gz
        rm -rf /root/subconverter_linux64.tar.gz
        read -p "请输入前端域名（不带https和www）: " domain
        replace_str="https://$domain/sub?"
        sed -i "s#http://127.0.0.1:25500/sub?#$replace_str#g" /root/sub-web/src/views/Subconverter.vue
        sed -i 's/ACL4SSR_Online 默认版 分组比较全 (与Github同步)/Openclash.ini/g' /root/sub-web/src/views/Subconverter.vue
        sed -i 's#https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/config/ACL4SSR_Online.ini#https://raw.githubusercontent.com/EnochKingsley83/Rule/main/openclash.ini#g' /root/sub-web/src/views/Subconverter.vue
        echo "替换完成"
        yarn build
        URL=https://www.aapanel.com/script/install_6.0_en.sh && if [ -f /usr/bin/curl ];then curl -ksSO "$URL" ;else wget --no-check-certificate -O install_6.0_en.sh "$URL";fi;bash install_6.0_en.sh aapanel
        sudo apt-get purge ufw
        sudo rm -rf /etc/ufw
        sudo rm -rf /lib/ufw
        echo "前端搭建完成，并自动安装了aapanel（宝塔面板）"
        echo "aapanel登录信息如下，请手动在aapanel反向代理里面添加sub和suc的子域名，并申请SSL证书，在suc的反向代理里面添加http://127.0.0.1:25500"
        bt
        echo 
        while true; do
            read -p "是否手动完成上述内，是输入y" choice
            if [ "$choice" = "Y" ] || [ "$choice" = "y" ]; then
                directory="/www/wwwroot/$domain"
                rm -rf "$directory"
                cp -r /root/sub-web/dist/* /www/wwwroot/$domain
                echo "恭喜，前端搭建完成"
                break
            else
                echo "输入不正确，请输入 Y 继续执行操作"
            fi
        done
        echo "后端搭建中..."
        cd /root
        sudo sed -i "s/api_access_token=password/api_access_token=SRG8EH43u8rT8UT01GVD6RT/g" /root/subconverter/pref.example.ini
        sudo sed -i "s/listen=0.0.0.0/listen=127.0.0.1/g" /root/subconverter/pref.example.ini
        sudo sed -i "s#managed_config_prefix=http://127.0.0.1:25500#managed_config_prefix=https://$domain#g" /root/subconverter/pref.example.ini
 
        sudo touch /etc/systemd/system/sub.service

        echo "[Unit]" >> /etc/systemd/system/sub.service
        echo "Description=Apply sysctl settings at boot" >> /etc/systemd/system/sub.service
        echo "After=network.target" >> /etc/systemd/system/sub.service

        echo "[Service]" >> /etc/systemd/system/sub.service
        echo "Type=simple" >> /etc/systemd/system/sub.service
        echo "ExecStart=/root/subconverter/subconverter" >> /etc/systemd/system/sub.service
        echo "Restart=always" >> /etc/systemd/system/sub.service
        echo "RestartSec=10" >> /etc/systemd/system/sub.service

        echo "[Install]" >> /etc/systemd/system/sub.service
        echo "WantedBy=multi-user.target" >> /etc/systemd/system/sub.service
        sudo systemctl daemon-reload
        sudo systemctl enable sysctl-p.service
        sudo systemctl start sysctl-p.service
        echo "后端搭建完成"
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
