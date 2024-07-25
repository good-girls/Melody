#!/usr/bin/env bash

sh_v="1.0.1"

# 定义颜色代码
huang='\033[33m'
bai='\033[0m'
lv='\033[0;32m'
lan='\033[0;34m'
hong='\033[31m'
kjlan='\033[96m'
hui='\e[37m'

# 标志文件路径
flag_file="/var/tmp/melody_first_run"

CheckRoot_true() {
    if [[ $EUID -ne 0 ]]; then
      echo -e "${hong}请使用root用户运行脚本！ ${bai}"
      exit 1
    fi
}

send_stats() {
    echo "Logging stats: $1"  # 这里你可以实现实际的日志记录功能
}

CheckFirstRun_false() {
    echo "进入 CheckFirstRun_false 函数"
    if [[ ! -f $flag_file ]]; then
        echo "检测到第一次运行，显示许可协议"
        UserLicenseAgreement
    else
        echo "不是第一次运行或许可已经接受"
        Melody_sh  # 确保调用主菜单函数
    fi
    echo "CheckFirstRun_false 函数结束"
}

UserLicenseAgreement() {
    clear
    echo -e "${lan}Melody，你的幸运之声！——Docker for Telegram Lottery Bot${bai}"
    echo -e "${lan}欢迎使用Melody抽奖机器人！${bai}"
    echo -e "----------------------"
    read -r -p "是否继续运行脚本？(y/n): " user_input

    if [ "$user_input" = "y" ] || [ "$user_input" = "Y" ]; then
        send_stats "许可同意"
        # 创建标志文件以标记许可已经同意
        touch "$flag_file"
    else
        send_stats "许可拒绝"
        clear
        exit 1
    fi
}

# 确保脚本以root用户运行
CheckRoot_true

# 检查是否是第一次运行
CheckFirstRun_false

Melody_sh() {
    while true; do
        clear

        echo -e "${kjlan}_  _ ____  _ _ _    _ ____ _  _ "
        echo " __  __  _____  _      ____   ___   _  __  __ "
        echo "|  \/  || ____|| |    |  _ \ |_ _| | |/ / / /"
        echo "| |\/| ||  _|  | |    | | | | | |  | ' / / / "
        echo "| |  | || |___ | |___ | |_| | | |  | . \ \ \ "
        echo "|_|  |_||_____||_____||____/|___| |_|\_\ \_\ "
        echo -e "${kjlan}Melody抽奖机器人 v$sh_v ！"
        echo "------------------------"
        echo "1. 直接安装"
        echo "2. docker 安装"
        echo "------------------------"
        echo "0. 退出脚本"
        echo "------------------------"
        read -p "请输入你的选择: " choice

        case $choice in
            1)
                clear
                melody_sh
                ;;

            2)
                clear
                send_stats "docker 安装"
                melody_docker
                ;;

            0)
                clear
                exit
                ;;

            *)
                echo "无效的输入!"
                read -p "按任意键重新选择..."
                ;;
        esac
    done
}



melody_sh() {
    echo -e "${huang}正在安装脚本...${bai}"

    apt update && apt upgrade -y

    python3_command=$(which python3)
    pip3_command=$(which pip3)
    if [[ -z "$python3_command" ]]; then
        apt install python3 python3-pip -y
    fi

    if [[ -z "$pip3_command" ]]; then
        apt install python3-pip -y
    fi

    pip3 install python-telegram-bot --upgrade
    pip3 install "python-telegram-bot[job-queue]"

    curl -L -o /root/Melody-sh.py https://raw.githubusercontent.com/good-girls/Melody/main/Melody-sh.py

    echo "${lv}获取脚本成功！${bai}"

    # 获取 API 并替换脚本
    read -p "${lan}请输入你从@BotFather获取的完整机器人API： ${bai}" API
    sed -i "s/application = Application.builder().token(\"你的机器人token\").build()/application = Application.builder().token(\"$API\").build()/g" /root/Melody-sh.py

    # 执行脚本
    echo "${lv}正在启动 Melody-sh.py 脚本...${bai}"
    python3 /root/Melody-sh.py &
    echo "${lv}脚本已启动，后台运行...${bai}"
}

melody_docker() {
    while true; do
        clear
        # send_stats "docker管理"
        echo "▶ 即将使用Docker安装"
        echo "------------------------"
        echo "y. 是否继续安装"
        echo "------------------------"
        echo "0. 返回上一级选单"
        echo "------------------------"
        read -p "请输入你的选择: " sub_choice

        case $sub_choice in
            y)
                clear
                send_stats "docker 安装"
                install_add_docker
                break
                ;;

            0)
                clear
                return
                ;;

            *)
                echo "无效的输入!"
                read -p "按任意键重新选择..."
                ;;
        esac
    done
}



install_add_docker_guanfang() {
country=$(curl -s ipinfo.io/country)
if [ "$country" = "CN" ]; then
    cd ~
    curl -sS -O https://raw.githubusercontent.com/good-girls/Melody/main/install && chmod +x install
    sh install --mirror Aliyun
    rm -f install
    cat > /etc/docker/daemon.json << EOF
{
    "registry-mirrors": ["https://docker.jose.us.kg"]
}
EOF

else
    curl -fsSL https://get.docker.com | sh
fi

}



install_add_docker() {
    echo -e "${huang}正在安装docker环境...${bai}"
    
    if [ -f /etc/os-release ] && grep -q -e "Debian" -e "Ubuntu" /etc/os-release; then
        apt update
        apt upgrade -y
        apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
        rm -f /usr/share/keyrings/docker-archive-keyring.gpg
        country=$(curl -s ipinfo.io/country)
        arch=$(uname -m)
        
        if [ "$country" = "CN" ]; then
            if [ "$arch" = "x86_64" ]; then
                sed -i '/^deb \[arch=amd64 signed-by=\/etc\/apt\/keyrings\/docker-archive-keyring.gpg\] https:\/\/mirrors.aliyun.com\/docker-ce\/linux\/debian bullseye stable/d' /etc/apt/sources.list.d/docker.list > /dev/null
                mkdir -p /etc/apt/keyrings
                curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker-archive-keyring.gpg > /dev/null
                echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker-archive-keyring.gpg] https://mirrors.aliyun.com/docker-ce/linux/debian bullseye stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
            elif [ "$arch" = "aarch64" ]; then
                sed -i '/^deb \[arch=arm64 signed-by=\/etc\/apt\/keyrings\/docker-archive-keyring.gpg\] https:\/\/mirrors.aliyun.com\/docker-ce\/linux\/debian bullseye stable/d' /etc/apt/sources.list.d/docker.list > /dev/null
                mkdir -p /etc/apt/keyrings
                curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker-archive-keyring.gpg > /dev/null
                echo "deb [arch=arm64 signed-by=/etc/apt/keyrings/docker-archive-keyring.gpg] https://mirrors.aliyun.com/docker-ce/linux/debian bullseye stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
            fi
        else
            if [ "$arch" = "x86_64" ]; then
                sed -i '/^deb \[arch=amd64 signed-by=\/usr\/share\/keyrings\/docker-archive-keyring.gpg\] https:\/\/download.docker.com\/linux\/debian bullseye stable/d' /etc/apt/sources.list.d/docker.list > /dev/null
                mkdir -p /etc/apt/keyrings
                curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker-archive-keyring.gpg > /dev/null
                echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian bullseye stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
            elif [ "$arch" = "aarch64" ]; then
                sed -i '/^deb \[arch=arm64 signed-by=\/usr\/share\/keyrings\/docker-archive-keyring.gpg\] https:\/\/download.docker.com\/linux\/debian bullseye stable/d' /etc/apt/sources.list.d/docker.list > /dev/null
                mkdir -p /etc/apt/keyrings
                curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker-archive-keyring.gpg > /dev/null
                echo "deb [arch=arm64 signed-by=/etc/apt/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian bullseye stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
            fi
        fi
        
        apt update
        apt install -y docker-ce docker-ce-cli containerd.io
    
    else
        echo "不支持的操作系统。"
    fi
    
    sleep 2
}


install_docker() {
    if ! command -v docker &>/dev/null; then
        install_add_docker
    else
        echo -e "${lv}Docker环境已经安装${bai}"
    fi
    
    # 获取 API 并替换命令
    clear
    read -p "请输入你从@BotFather获取的完整机器人API： " API
    docker run -d \
      -e TELEGRAM_BOT_TOKEN="$API" \
      --name melody \
      josemespitia/melody:latest

    echo "Melody-Bot 已启动，后台运行..."
}