#!/usr/bin/env bash
set -Eeuo pipefail

# 项目: Nginx Proxy Manager 一键卸载脚本
# 作者: Facker668

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

NPM_DIR="/opt/npm"

compose_cmd() {
  if docker compose version >/dev/null 2>&1; then
    echo "docker compose"
  elif command -v docker-compose >/dev/null 2>&1; then
    echo "docker-compose"
  else
    echo ""
  fi
}

echo -e "${RED}即将开始卸载 Nginx Proxy Manager 及其数据...${NC}"
read -r -p "此操作不可逆，确认继续? (y/n): " confirm

if [[ "${confirm}" == "y" ]]; then
  if [[ -d "${NPM_DIR}" ]]; then
    cd "${NPM_DIR}"
    compose=$(compose_cmd)
    if [[ -n "${compose}" ]]; then
      ${compose} down || true
    fi
    cd /
    rm -rf "${NPM_DIR}"
    echo -e "${GREEN}NPM 数据目录已清理。${NC}"
  else
    echo -e "${YELLOW}未发现 ${NPM_DIR}，跳过容器清理。${NC}"
  fi

  sed -i '/alias npm=/d' ~/.bashrc || true
  rm -f /usr/local/bin/npm_tool.sh

  echo -e "${RED}卸载完成。${NC}"
else
  echo "操作已取消。"
fi
