# Деплой на qrobotics.sargeras.ru (HTTPS, Let's Encrypt)

## 1. Сборка приложения

На машине разработки (или в CI):

```bash
bun run deploy:build
```

Собранные файлы будут в `example/dist/`.

## 2. Деплой на сервер

Скопируйте содержимое `example/dist/` на сервер в каталог, с которого будет отдавать nginx (по умолчанию `/var/www/qrobotics.sargeras.ru`):

```bash
rsync -av example/dist/ user@your-server:/var/www/qrobotics.sargeras.ru/
```

## 3. Настройка HTTPS на сервере

На сервере (Ubuntu/Debian):

1. Установите nginx и certbot:
   ```bash
   sudo apt update
   sudo apt install nginx certbot python3-certbot-nginx
   ```

2. Убедитесь, что DNS для **qrobotics.sargeras.ru** указывает на IP этого сервера.

3. Скопируйте папку `scripts/` из репозитория на сервер.

4. Задайте email для Let's Encrypt и запустите:
   ```bash
   export CERTBOT_EMAIL=your@email.com
   sudo bash scripts/setup-https-nginx.sh
   ```

Сайт будет доступен по **https://qrobotics.sargeras.ru**.

## Обновление сертификата

Проверка продления: `sudo certbot renew --dry-run`
