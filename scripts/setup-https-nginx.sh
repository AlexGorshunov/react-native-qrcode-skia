#!/usr/bin/env bash
# Настройка HTTPS (Let's Encrypt) и nginx для qrobotics.sargeras.ru
# Запускать на сервере с root (или sudo). Требует: nginx, certbot, certbot python3 nginx plugin
#
# Использование:
#   1. Убедитесь, что DNS для qrobotics.sargeras.ru указывает на этот сервер
#   2. Скопируйте собранное приложение в /var/www/qrobotics.sargeras.ru (или задайте SITE_ROOT)
#   3. Запустите: sudo ./setup-https-nginx.sh

set -euo pipefail

DOMAIN="qrobotics.sargeras.ru"
EMAIL="${CERTBOT_EMAIL:-$1}"  # export CERTBOT_EMAIL=... или первый аргумент
SITE_ROOT="${SITE_ROOT:-/var/www/qrobotics.sargeras.ru}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NGINX_CONF="$SCRIPT_DIR/nginx-qrobotics.sargeras.ru.conf"

if [[ -z "$EMAIL" ]]; then
  echo "Задайте email для Let's Encrypt: export CERTBOT_EMAIL=your@email.com"
  exit 1
fi

echo "==> Домен: $DOMAIN"
echo "==> Корень сайта: $SITE_ROOT"
echo "==> Email для сертификата: $EMAIL"

# Создать каталог для ACME challenge
sudo mkdir -p /var/www/certbot
sudo chown -R www-data:www-data /var/www/certbot 2>/dev/null || true

# Временный nginx только для HTTP (чтобы certbot мог получить сертификат)
TMP_CONF="/etc/nginx/sites-available/$DOMAIN-tmp"
sudo tee "$TMP_CONF" << 'NGINX_TMP'
server {
    listen 80;
    server_name qrobotics.sargeras.ru;
    root /var/www/certbot;
    location /.well-known/acme-challenge/ { allow all; }
    location / { return 200 'ok'; add_header Content-Type text/plain; }
}
NGINX_TMP

sudo ln -sf "/etc/nginx/sites-available/$DOMAIN-tmp" "/etc/nginx/sites-enabled/$DOMAIN-tmp" 2>/dev/null || true
sudo nginx -t && sudo systemctl reload nginx

echo "==> Получение сертификата Let's Encrypt..."
sudo certbot certonly --webroot -w /var/www/certbot -d "$DOMAIN" --email "$EMAIL" --agree-tos --non-interactive

# Генерация dhparams если ещё нет
if [[ ! -f /etc/letsencrypt/ssl-dhparams.pem ]]; then
  sudo openssl dhparam -out /etc/letsencrypt/ssl-dhparams.pem 2048
fi

# Подставить путь к конфигу (скрипт может запускаться не из репо)
FINAL_CONF="/etc/nginx/sites-available/$DOMAIN"
sudo cp "$NGINX_CONF" "$FINAL_CONF"
sudo rm -f "/etc/nginx/sites-enabled/$DOMAIN-tmp"
sudo ln -sf "$FINAL_CONF" /etc/nginx/sites-enabled/

# Создать корень сайта и напомнить скопировать файлы
sudo mkdir -p "$SITE_ROOT"
echo "==> Каталог сайта: $SITE_ROOT"
echo "   Скопируйте содержимое example/dist в $SITE_ROOT (например: rsync -av example/dist/ server:$SITE_ROOT/)"

sudo nginx -t && sudo systemctl reload nginx
echo "==> Nginx перезагружен. HTTPS: https://$DOMAIN"

# Автообновление сертификата (cron уже ставится certbot при установке)
echo "==> Проверка автообновления: sudo certbot renew --dry-run"
