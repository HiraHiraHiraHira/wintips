#!/usr/bin/env bash
# 构建静态站点到 dist/。只依赖 devDependencies，不引入运行时依赖。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [ ! -x node_modules/.bin/tailwindcss ]; then
  echo "缺少 tailwindcss，先执行 npm install" >&2
  exit 1
fi

rm -rf dist
mkdir -p dist/assets

node_modules/.bin/tailwindcss \
  -i src/styles.css \
  -o dist/assets/main.css \
  --minify

cp src/index.html dist/index.html

echo "构建完成:"
du -h dist/index.html dist/assets/main.css | sed 's/^/  /'
