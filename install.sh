#!/bin/bash
set -e

echo "[*] Update & install dependencies..."
apt update -y
apt install -y python3 python3-pip git

echo "[*] Clone repository bot..."
if [ -d "/opt/cfbot" ]; then
  echo "Folder /opt/cfbot sudah ada, menarik update terbaru..."
  cd /opt/cfbot
  git pull
else
  git clone https://github.com/vermiliion/cfbot.git /opt/cfbot
  cd /opt/cfbot
fi

echo "[*] Install Python dependencies..."
pip3 install -r requirements.txt

echo -n "[*] Masukkan token BOT Telegram Anda: "
read BOT_TOKEN

if [[ -z "$BOT_TOKEN" ]]; then
  echo "Token bot tidak boleh kosong!"
  exit 1
fi

echo "BOT_TOKEN=$BOT_TOKEN" > .env

echo "[*] Membuat service systemd cfbot.service..."

cat > /etc/systemd/system/cfbot.service <<EOF
[Unit]
Description=Cloudflare Telegram Bot
After=network.target

[Service]
User=root
WorkingDirectory=/opt/cfbot
ExecStart=/usr/bin/python3 bot.py
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo "[*] Reload systemd daemon..."
systemctl daemon-reload

echo "[*] Enable dan start service cfbot..."
systemctl enable cfbot.service
systemctl start cfbot.service

echo "[*] Instalasi selesai. Service berjalan dengan status:"
systemctl status cfbot.service --no-pager
exit 1
