#!/usr/bin/env bash
# 幂等部署：构建 → 同步 dist 到 1Panel 站点目录 → 写 vhost → 校验并重载
#
# 用法：
#   bash deploy/deploy.sh                 # 部署到 wintips.hiralia.com
#   DOMAIN=foo.example.com bash deploy/deploy.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DOMAIN="${DOMAIN:-wintips.hiralia.com}"
ALIAS="${ALIAS:-$(echo "$DOMAIN" | tr -d '.')}"
SITES_ROOT="${SITES_ROOT:-/opt/1panel/www/sites}"
CONF_DIR="${CONF_DIR:-/opt/1panel/www/conf.d}"
OPENRESTY="${OPENRESTY:-1Panel-openresty-wwJl}"
SITE_DIR="$SITES_ROOT/$ALIAS"

echo "==> 构建"
bash "$ROOT/scripts/build.sh"

echo "==> 准备站点目录 $SITE_DIR"
mkdir -p "$SITE_DIR"/{index,log,proxy,ssl}
rm -rf "$SITE_DIR/index"/*
cp -r "$ROOT/dist/." "$SITE_DIR/index/"

echo "==> 写入虚拟主机配置"
sed -e "s|__DOMAIN__|$DOMAIN|g" -e "s|__ALIAS__|$ALIAS|g" \
  "$ROOT/deploy/nginx.conf" > "$CONF_DIR/$DOMAIN.conf"

echo "==> 校验并重载 OpenResty"
docker exec "$OPENRESTY" nginx -t
docker exec "$OPENRESTY" nginx -s reload

echo "==> 回源验证"
code=$(curl -s -o /dev/null -w '%{http_code}' -H "Host: $DOMAIN" http://127.0.0.1/)
echo "  http://127.0.0.1/ -> $code"
[ "$code" = "200" ] || { echo "回源失败" >&2; exit 1; }

echo "完成: https://$DOMAIN"
