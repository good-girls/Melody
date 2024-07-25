#!/bin/bash

huang='\033[33m'
bai='\033[0m'
lv='\033[0;32m'
lan='\033[0;34m'
hong='\033[31m'
kjlan='\033[96m'
hui='\e[37m'

sh_v="1.1.2"
FLAG_FILE="$HOME/.melody_installed"
PID_FILE="/tmp/melody_sh.pid"
SCRIPT_PATH="/root/Melody-sh.py"
VENV_PATH="/root/myenv"

CheckRoot_true() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${hong}请使用root用户运行脚本！${bai}"
        exit 1
    fi
}

UserLicenseAgreement() {
    clear
    echo -e "${kjlan}Melody，你的幸运之声！——Docker for Telegram Lottery Bot${bai}"
    echo -e "${lv}欢迎使用Melody抽奖机器人！${bai}"
    echo "----------------------"
    read -r -p "${huang}是否继续运行脚本？(y/n):${bai}" user_input

    if [[ "$user_input" == "y" || "$user_input" == "Y" ]]; then
        touch "$FLAG_FILE"
    else
        clear
        exit 1
    fi
}

check_if_melody_running() {
    if [[ -f "$PID_FILE" ]]; then
        if ps -p "$(cat "$PID_FILE")" > /dev/null; then
            echo "${hui}Melody已在后台运行${bai}"
            exit 1
        else
            rm -f "$PID_FILE"
        fi
    fi
}

uninstall_melody() {
    check_if_melody_running

    echo -e "正在卸载Melody..."

    # 停止并删除运行中的进程
    if [[ -f "$PID_FILE" ]]; then
        kill "$(cat "$PID_FILE")"
        rm -f "$PID_FILE"
        echo "已停止运行的脚本"
    fi

    # 删除虚拟环境
    if [[ -d "$VENV_PATH" ]]; then
        rm -rf "$VENV_PATH"
        echo "已删除虚拟环境"
    fi

    # 删除脚本
    if [[ -f "$SCRIPT_PATH" ]]; then
        rm -f "$SCRIPT_PATH"
        echo "已删除脚本文件"
    fi

    # 删除标志文件
    if [[ -f "$FLAG_FILE" ]]; then
        rm -f "$FLAG_FILE"
        echo "已删除标志文件"
    fi

    echo "Melody卸载完成"
}

Melody_sh() {
    check_if_melody_running

    while true; do
        clear
        echo -e "_  _ ____  _ _ _    _ ____ _  _ "
        echo " __  __  _____  _      ____   ___   _  __  __ "
        echo "|  \/  || ____|| |    |  _ \ |_ _| | |/ / / /"
        echo "| |\/| ||  _|  | |    | | | | | |  | ' / / / "
        echo "| |  | || |___ | |___ | |_| | | |  | . \ \ \ "
        echo "|_|  |_||_____||_____||____/|___| |_|\_\ \_\ "
        echo -e "${lan}Melody抽奖机器人 v$sh_v ！${bai}"
        echo "------------------------"
        echo "1. 直接安装"
        echo "2. docker 安装"
        echo "------------------------"
        echo "00. 卸载脚本"
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
                melody_docker
                ;;

            00)
                clear
                uninstall_melody
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
    check_if_melody_running

    echo -e "正在安装脚本..."

    apt update && apt upgrade -y

    # 检查并安装 python3-venv
    apt install -y python3-venv

    # 创建虚拟环境
    python3 -m venv "$VENV_PATH"

    # 激活虚拟环境并安装 python-telegram-bot
    source "$VENV_PATH/bin/activate"
    pip install python-telegram-bot

    curl -L -o "$SCRIPT_PATH" https://raw.githubusercontent.com/good-girls/Melody/main/Melody-sh.py

    echo "获取脚本成功！"

    # 获取 API 并替换脚本
    read -p "请输入你从@BotFather获取的完整机器人API： " API
    sed -i "s/application = Application.builder().token(\"你的机器人token\").build()/application = Application.builder().token(\"$API\").build()/g" "$SCRIPT_PATH"

    # 执行脚本
    echo "正在启动 Melody-sh.py 脚本..."
    /root/myenv/bin/python "$SCRIPT_PATH" &
    echo $! > "$PID_FILE"
    echo "脚本已启动，后台运行..."
}

melody_docker() {
    while true; do
        clear
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
    echo -e "正在安装docker环境..."
    
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
        echo -e "Docker环境已经安装"
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

# 主程序逻辑
CheckRoot_true

if [ ! -f "$FLAG_FILE" ]; then
    UserLicenseAgreement
fi

Melody_sh
