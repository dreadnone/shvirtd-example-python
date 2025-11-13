#!/bin/bash
set -e

if [ $# -lt 2 ]; then
    echo "Использование: $0 <github_username> <github_token> [repo_name]"
    echo "Пример: $0 myusername ghp_abc123 shvirtd-example-python"
    exit 1
fi

GITHUB_USER=$1
GITHUB_TOKEN=$2
REPO_NAME=${3:-"shvirtd-example-python"}

echo "=== Обновление системы и установка Docker ==="
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

echo "=== Установка Docker Compose ==="
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "=== Клонирование репозитория ==="
sudo mkdir -p /opt/app
cd /opt/app
sudo git clone https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${REPO_NAME}.git .
sudo chown -R $USER:$USER .

echo "=== Создание .env файла ==="
cat > .env << EOF
MYSQL_ROOT_PASSWORD=YtReWq4321
MYSQL_DATABASE=virt
MYSQL_USER=app
MYSQL_PASSWORD=QwErTy1234
EOF

echo "=== Запуск приложения ==="
sudo docker-compose down || true
sudo docker-compose up -d

echo "=== Проверка работы ==="
sleep 30
curl -L http://localhost:8090

echo "=== Развертывание завершено ==="
EXTERNAL_IP=$(curl -s ifconfig.me)
echo "Приложение доступно по адресу: http://${EXTERNAL_IP}:8090"