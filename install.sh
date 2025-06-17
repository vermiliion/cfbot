#!/bin/bash
echo "[*] Update & Install Python3 pip..."
apt update -y && apt install -y python3 python3-pip

echo "[*] Cloning project..."
unzip cloudflare_bot_pro.zip -d /opt/
cd /opt/cloudflare_bot_pro

echo "[*] Install requirements..."
pip3 install -r requirements.txt

echo '[*] Setup .env'
echo 'BOT_TOKEN=ISI_TOKEN_BOTMU' > .env

echo '[*] Bot siap dijalankan dengan: python3 bot.py'