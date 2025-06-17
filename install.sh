#!/bin/bash
set -e

echo "[*] Deteksi OS..."
if [ -f /etc/debian_version ]; then
  OS="debian"
elif [ -f /etc/redhat-release ]; then
  OS="redhat"
else
  echo "OS tidak dikenali. Script ini mendukung Debian/Ubuntu dan CentOS/RHEL."
  exit 1
fi

echo "[*] Cek dan hapus bot lama jika ada..."
if systemctl is-active --quiet cfbot.service; then
  echo "Mematikan service cfbot.service..."
  systemctl stop cfbot.service
fi

if systemctl is-enabled --quiet cfbot.service; then
  echo "Menonaktifkan service cfbot.service..."
  systemctl disable cfbot.service
fi

if [ -f /etc/systemd/system/cfbot.service ]; then
  echo "Menghapus file service cfbot.service..."
  rm -f /etc/systemd/system/cfbot.service
fi

if [ -d "/opt/cfbot" ]; then
  echo "Menghapus folder /opt/cfbot lama..."
  rm -rf /opt/cfbot
fi

echo "[*] Update & install dependencies..."
if [ "$OS" = "debian" ]; then
  apt update -y
  apt install -y python3 python3-pip python3-venv git
elif [ "$OS" = "redhat" ]; then
  yum update -y
  yum install -y python3 python3-pip python3-venv git
fi

echo "[*] Clone repository bot..."
git clone https://github.com/vermiliion/cfbot.git /opt/cfbot
cd /opt/cfbot

echo "[*] Membuat virtual environment dan install dependencies..."
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
deactivate

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
ExecStart=/opt/cfbot/venv/bin/python /opt/cfbot/bot.py
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

exit 0
