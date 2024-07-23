#!/bin/bash

sh_v="1.0.1"

huang='\033[33m'
bai='\033[0m'
lv='\033[0;32m'
lan='\033[0;34m'
hong='\033[31m'
kjlan='\033[96m'
hui='\e[37m'

echo "${lan}Melody，你的幸运之声！——Docker for Telegram Lottery Bot${bai}"
echo "${lan}欢迎使用Melody抽奖机器人！${bai}"
read -p "${lan}是否继续运行脚本？(y/n) ${bai}" answer

if [[ "$answer" =~ ^[yY]$ ]]; then
  echo "${lv}继续运行脚本...${bai}"

  while true; do
    echo "${lan}Melody Lottery-Bot Script：${bai}"
    echo "${lan}1. 直接安装${bai}"
    echo "${lan}2. docker 安装${bai}"
    echo "${lan}0. 退出脚本${bai}"
    read -p "${lan}请输入你的选择 [0-2]: ${bai}" choice

    if [[ "$choice" =~ ^[0-2]$ ]]; then
      if [[ "$choice" == "0" ]]; then
        echo "${lan}退出脚本...${bai}"
        exit 0
      elif [[ "$choice" == "1" ]]; then
        echo "${lv}获取脚本中...${bai}"
        # 直接安装逻辑
        apt update && apt upgrade -y
        if ! command -v python3 &> /dev/null; then
          apt install python3 python3-pip -y
        fi
        pip install python-telegram-bot --upgrade
        pip install "python-telegram-bot[job-queue]"
        curl -L -o /root/Melody-sh.py https://raw.githubusercontent.com/good-girls/Melody/main/Melody-sh.py
        echo "${lv}获取脚本成功！${bai}"

        # 获取 API 并替换脚本
        read -p "${lan}请输入你从@BotFather获取的完整机器人API： ${bai}" API
        sed -i "s/application = Application.builder().token(\"你的机器人token\").build()/application = Application.builder().token(\"$API\").build()/g" /root/Melody-sh.py

        # 执行脚本
        echo "${lv}正在启动 Melody-sh.py 脚本...${bai}"
        python /root/Melody-sh.py
        echo "${lv}脚本已启动，后台运行...${bai}"
        nohup python /root/Melody-sh.py &
      elif [[ "$choice" == "2" ]]; then
        echo "${lv}docker 安装...${bai}"
        # docker 安装逻辑
        apt update && apt upgrade -y
        if command -v docker &> /dev/null; then
          echo "${lv}已安装 docker${bai}"
        else
          echo "${lv}正在安装 docker...${bai}"
          curl -sSL https://get.docker.com/ | sh
        fi

        # 获取 API 并替换命令
        read -p "${lan}请输入你从@BotFather获取的完整机器人API： ${bai}" API
        docker run -d \
          -e TELEGRAM_BOT_TOKEN="$API" \
          --name melody \
          josemespitia/melody:latest

        echo "${lv}Melody-Bot 已启动，后台运行...${bai}"
      fi
      break
    else
      echo "${hong}无效的输入${bai}"
      echo "${lv}操作完成${bai}"
      read -p "${lan}请按任意键继续...${bai}" -n 1 -r
      echo ""
    fi
  done

elif [[ "$answer" =~ ^[nN]$ ]]; then
  echo "${lan}退出脚本...${bai}"
  exit 1
else
  echo "${hong}输入无效，退出脚本...${bai}"
  exit 1
fi