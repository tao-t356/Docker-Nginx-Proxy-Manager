#!/usr/bin/env bash
set -Eeuo pipefail

# ========================================================
# 项目名称: Nginx Proxy Manager 综合管理脚本
# 项目作者: facker668
# 联系邮箱: tao356334@gmail.com
# 项目地址: https://github.com/tao-t356/Docker-Nginx-Proxy-Manager
# ========================================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

NPM_DIR="/opt/npm"
NPM_IMAGE="${NPM_IMAGE:-jc21/nginx-proxy-manager:latest}"

# 核心检查：必须是 Root 才能运行
if [[ "${EUID}" -ne 0 ]]; then
  echo -e "${RED}错误：此脚本必须使用 root 权限运行！${NC}"
  echo -e "${YELLOW}请尝试使用 'sudo bash $0' 或切换到 root 用户再运行。${NC}"
  exit 1
fi

compose_cmd() {
  if docker compose version >/dev/null 2>&1; then
    echo "docker compose"
  elif command -v docker-compose >/dev/null 2>&1; then
    echo "docker-compose"
  else
    echo ""
  fi
}

is_port_busy() {
  local port="$1"
  if command -v ss >/dev/null 2>&1; then
    ss -ltn "( sport = :${port} )" | grep -q LISTEN
  elif command -v lsof >/dev/null 2>&1; then
    lsof -Pi :"${port}" -sTCP:LISTEN -t >/dev/null
  else
    # 无检测工具时，保守返回“未占用”
    return 1
  fi
}

print_panel_info() {
  local ip=""
  ip=$(curl -s4m5 ifconfig.me || curl -s4m5 icanhazip.com || true)

  if [[ -z "${ip}" ]]; then
    local ipv6
    ipv6=$(curl -s6m5 ifconfig.me || curl -s6m5 icanhazip.com || true)
    if [[ -n "${ipv6}" ]]; then
      ip="[${ipv6}]"
    else
      ip="您的服务器IP"
    fi
  fi

  echo -e "\n${CYAN}==================================================${NC}"
  echo -e "${GREEN}         Nginx Proxy Manager 安装成功！          ${NC}"
  echo -e "${CYAN}==================================================${NC}"
  echo -e "管理面板地址: ${YELLOW}http://${ip}:81${NC}"
  echo -e ""
  echo -e "${GREEN}数据目录：${NC}${NPM_DIR}/data"
  echo -e "${GREEN}证书目录：${NC}${NPM_DIR}/letsencrypt"
  echo -e "${GREEN}首次登录指引：${NC}"
  echo -e " 1. 请在浏览器中访问上方管理地址"
  echo -e " 2. 系统将引导您${YELLOW}直接创建${NC}管理员账号"
  echo -e " 3. 请妥善保管您设置的邮箱和密码"
  echo -e "${CYAN}==================================================${NC}"
}

health_check() {
  local ok=1
  for _ in {1..15}; do
    if curl -fsS --max-time 3 http://127.0.0.1:81 >/dev/null 2>&1; then
      ok=0
      break
    fi
    sleep 2
  done

  if [[ "${ok}" -eq 0 ]]; then
    echo -e "${GREEN}服务健康检查通过（http://127.0.0.1:81 可访问）${NC}"
  else
    echo -e "${YELLOW}提示：容器已启动，但本机 81 端口暂不可访问，请稍后重试。${NC}"
  fi
}

# 菜单主界面
show_menu() {
  clear
  echo -e "${CYAN}==================================================${NC}"
  echo -e "${CYAN}        Nginx Proxy Manager 综合管理脚本          ${NC}"
  echo -e "${CYAN}    作者: facker668 | Email: tao356334@gmail.com  ${NC}"
  echo -e "${CYAN}==================================================${NC}"
  echo -e "${GREEN}  1.${NC} 安装 Docker 环境"
  echo -e "${GREEN}  2.${NC} 安装 Nginx Proxy Manager (NPM)"
  echo -e "${GREEN}  3.${NC} 卸载 Nginx Proxy Manager (NPM)"
  echo -e "${GREEN}  4.${NC} 卸载 Docker 环境（危险）"
  echo -e "${RED}  0.${NC} 退出脚本"
  echo -e "${CYAN}==================================================${NC}"
  read -r -p "请输入选项 [0-4]: " choice
}

install_docker() {
  echo -e "\n${YELLOW}正在检查并安装 Docker...${NC}"
  if ! command -v docker >/dev/null 2>&1; then
    curl -fsSL https://get.docker.com | sh
    systemctl enable --now docker
    echo -e "${GREEN}Docker 安装完成！${NC}"
  else
    echo -e "${GREEN}Docker 已存在，跳过安装。${NC}"
  fi
}

install_npm() {
  if ! command -v docker >/dev/null 2>&1; then
    echo -e "${RED}错误：请先执行选项 1 安装 Docker 环境！${NC}"
    return
  fi

  local compose
  compose=$(compose_cmd)
  if [[ -z "${compose}" ]]; then
    echo -e "${RED}错误：未检测到 Docker Compose（docker compose 或 docker-compose）。${NC}"
    return
  fi

  echo -e "${YELLOW}正在检查端口占用情况...${NC}"
  for port in 80 81 443; do
    if is_port_busy "${port}"; then
      echo -e "${RED}错误：端口 ${port} 已被占用，请先关闭相关服务后再安装。${NC}"
      return
    fi
  done

  echo -e "\n${YELLOW}开始安装 Nginx Proxy Manager...${NC}"
  mkdir -p "${NPM_DIR}"
  cd "${NPM_DIR}"

  cat <<EOF > docker-compose.yml
version: '3.8'
services:
  app:
    image: '${NPM_IMAGE}'
    restart: unless-stopped
    ports:
      - '80:80'
      - '81:81'
      - '443:443'
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
EOF

  ${compose} up -d

  health_check
  print_panel_info
}

uninstall_npm() {
  read -r -p "确定要彻底卸载 NPM 并删除所有数据吗? (y/n): " confirm
  if [[ "${confirm}" == "y" ]]; then
    echo -e "${YELLOW}正在停止并清理 NPM...${NC}"
    if [[ -d "${NPM_DIR}" ]]; then
      cd "${NPM_DIR}"
      local compose
      compose=$(compose_cmd)
      if [[ -n "${compose}" ]]; then
        ${compose} down || true
      fi
      cd /
      rm -rf "${NPM_DIR}"
      echo -e "${GREEN}NPM 已成功卸载。${NC}"
    else
      echo -e "${RED}未发现安装目录 ${NPM_DIR}。${NC}"
    fi
  else
    echo -e "${YELLOW}已取消。${NC}"
  fi
}

uninstall_docker() {
  echo -e "${RED}警告：此操作会删除整机 Docker 环境，可能影响其他容器业务！${NC}"
  read -r -p "请输入 YES_I_KNOW 继续: " confirm
  if [[ "${confirm}" == "YES_I_KNOW" ]]; then
    echo -e "${YELLOW}正在卸载 Docker...${NC}"
    if command -v apt-get >/dev/null 2>&1; then
      apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || true
      apt-get autoremove -y || true
    elif command -v yum >/dev/null 2>&1; then
      yum remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || true
    fi
    echo -e "${GREEN}Docker 已执行卸载流程。${NC}"
  else
    echo -e "${YELLOW}已取消卸载 Docker。${NC}"
  fi
}

while true; do
  show_menu
  case "${choice}" in
    1) install_docker ;;
    2) install_npm ;;
    3) uninstall_npm ;;
    4) uninstall_docker ;;
    0) echo -e "${GREEN}感谢使用！${NC}"; exit 0 ;;
    *) echo -e "${RED}无效选项！${NC}" ;;
  esac
  echo ""
  read -r -p "按回车键返回主菜单..." _dummy
done
