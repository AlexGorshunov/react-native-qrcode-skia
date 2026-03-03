#!/usr/bin/env bash
# Сборка веб-приложения для деплоя на qr.sargeras.ru
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
EXAMPLE_DIR="$ROOT_DIR/example"
OUTPUT_DIR="$EXAMPLE_DIR/dist"

echo "==> Сборка приложения (Expo web)..."
cd "$EXAMPLE_DIR"

# Статический рендер Expo Router ищет canvaskit.wasm в node_modules/expo-router/node/
# Копируем туда файл (из public/ после setup-skia-web или из canvaskit-wasm)
CANVASKIT_DEST="$ROOT_DIR/node_modules/expo-router/node/canvaskit.wasm"
CANVASKIT_SRC=
for p in "$EXAMPLE_DIR/public/canvaskit.wasm" "$ROOT_DIR/node_modules/canvaskit-wasm/bin/full/canvaskit.wasm" "$EXAMPLE_DIR/node_modules/canvaskit-wasm/bin/full/canvaskit.wasm"; do
  if [[ -f "$p" ]]; then CANVASKIT_SRC="$p"; break; fi
done
if [[ -n "$CANVASKIT_SRC" ]]; then
  mkdir -p "$(dirname "$CANVASKIT_DEST")"
  cp "$CANVASKIT_SRC" "$CANVASKIT_DEST"
  echo "==> Скопирован canvaskit.wasm для SSR: $CANVASKIT_DEST"
else
  echo "==> Предупреждение: canvaskit.wasm не найден, SSR может упасть. Выполните bun install и postinstall в example."
fi

# В workspace зависимости могут быть в example или в корне — добавляем оба .bin в PATH
export PATH="$EXAMPLE_DIR/node_modules/.bin:$ROOT_DIR/node_modules/.bin:$PATH"
bun run predeploy

echo "==> Сборка завершена. Статика в: $OUTPUT_DIR"
echo "   Для деплоя скопируйте содержимое на сервер и настройте nginx (см. scripts/setup-https-nginx.sh)"
