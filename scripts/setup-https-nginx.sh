#!/usr/bin/env bash
# Настройка HTTPS (Let's Encrypt) и nginx для qr.sargeras.ru и www.qr.sargeras.ru
# Запускать на сервере с root (или sudo). Требует: nginx, certbot
#
# Использование:
#   1. Убедитесь, что DNS для qr.sargeras.ru и www.qr.sargeras.ru указывает на этот сервер
#   2. Скопируйте собранное приложение в /var/www/qr.sargeras.ru (или задайте SITE_ROOT)
#   3. Запустите: sudo ./setup-https-nginx.sh [email]

set -euo pipefail

DOMAIN="qr.sargeras.ru"
DOMAIN_WWW="www.qr.sargeras.ru"
EMAIL="${CERTBOT_EMAIL:-$1}"
SITE_ROOT="${SITE_ROOT:-/var/www/qr.sargeras.ru}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NGINX_CONF="$SCRIPT_DIR/nginx-qr.sargeras.ru.conf"

if [[ -z "$EMAIL" ]]; then
  echo "Задайте email для Let's Encrypt: export CERTBOT_EMAIL=your@email.com"
  exit 1
fi

echo "==> Домен: $DOMAIN"
echo "==> Корень сайта: $SITE_ROOT"
echo "==> Email для сертификата: $EMAIL"

sudo mkdir -p /var/www/certbot
sudo chown -R www-data:www-data /var/www/certbot 2>/dev/null || true

# Временный nginx для ACME (оба домена)
TMP_CONF="/etc/nginx/sites-available/$DOMAIN-tmp"
sudo bash -c "cat > '$TMP_CONF' << NGINX_TMP
server {
    listen 80;
    server_name $DOMAIN $DOMAIN_WWW;
    root /var/www/certbot;
    location /.well-known/acme-challenge/ { allow all; }
    location / { return 200 'ok'; add_header Content-Type text/plain; }
}
NGINX_TMP"

sudo ln -sf "/etc/nginx/sites-available/$DOMAIN-tmp" "/etc/nginx/sites-enabled/$DOMAIN-tmp" 2>/dev/null || true
sudo nginx -t && sudo systemctl reload nginx

echo "==> Получение сертификата Let's Encrypt для $DOMAIN и $DOMAIN_WWW..."
sudo certbot certonly --webroot -w /var/www/certbot -d "$DOMAIN" -d "$DOMAIN_WWW" --email "$EMAIL" --agree-tos --non-interactive --expand

if [[ ! -f /etc/letsencrypt/ssl-dhparams.pem ]]; then
  sudo openssl dhparam -out /etc/letsencrypt/ssl-dhparams.pem 2048
fi

FINAL_CONF="/etc/nginx/sites-available/$DOMAIN"
sudo cp "$NGINX_CONF" "$FINAL_CONF"
sudo rm -f "/etc/nginx/sites-enabled/$DOMAIN-tmp"
sudo ln -sf "$FINAL_CONF" /etc/nginx/sites-enabled/

sudo mkdir -p "$SITE_ROOT"
echo "==> Каталог сайта: $SITE_ROOT"

sudo nginx -t && sudo systemctl reload nginx
echo "==> Nginx перезагружен. HTTPS: https://$DOMAIN"
echo "==> Проверка продления: sudo certbot renew --dry-run"
