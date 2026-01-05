#!/bin/bash

# ==========================================
# 项目: Nginx Proxy Manager 综合管理脚本
# 作者: Facker668
# 说明: 需 Root 权限，不修改系统别名，纯净运行
# ==========================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# 核心检查：必须是 Root 才能运行
if [ "$EUID" -ne 0 ]; then 
  echo -e "${RED}错误：此脚本必须使用 root 权限运行！${NC}"
  echo -e "${YELLOW}请尝试使用 'sudo bash $0' 运行。${NC}"
  exit 1
fi

# 菜单主界面
show_menu() {
    clear
    echo -e "${CYAN}==================================================${NC}"
    echo -e "${CYAN}        Nginx Proxy Manager 综合管理脚本           ${NC}"
    echo -e "${CYAN}                作者: Facker668                   ${NC}"
    echo -e "${CYAN}==================================================${NC}"
    echo -e "${GREEN}  1.${NC} 安装 Docker 环境"
    echo -e "${GREEN}  2.${NC} 安装 Nginx Proxy Manager (NPM)"
    echo -e "${GREEN}  3.${NC} 卸载 Nginx Proxy Manager (NPM)"
    echo -e "${GREEN}  4.${NC} 卸载 Docker 环境"
    echo -e "${RED}  0.${NC} 退出脚本"
    echo -e "${CYAN}==================================================${NC}"
    read -p "请输入选项 [0-4]: " choice
}

# 1. 安装 Docker
install_docker() {
    echo -e "\n${YELLOW}正在检查并安装 Docker...${NC}"
    if ! command -v docker &> /dev/null; then
        curl -fsSL https://get.docker.com | sh
        systemctl enable --now docker
        echo -e "${GREEN}Docker 安装完成！${NC}"
    else
        echo -e "${GREEN}Docker 已存在，跳过安装。${NC}"
    fi
}

# 2. 安装 NPM
install_npm() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}错误：请先执行选项 1 安装 Docker 环境！${NC}"
        return
    fi
    echo -e "\n${YELLOW}开始安装 Nginx Proxy Manager...${NC}"
    mkdir -p /opt/npm && cd /opt/npm
    cat <<EOF > docker-compose.yml
version: '3.8'
services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
    restart: unless-stopped
    ports:
      - '80:80'
      - '81:81'
      - '443:443'
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
EOF
    docker compose up -d
    if [ $? -eq 0 ]; then
        IP=$(curl -s ifconfig.me)
        echo -e "${GREEN}NPM 安装成功！${NC}"
        echo -e "${CYAN}管理地址: http://${IP}:81${NC}"
        echo -e "${YELLOW}默认账号: admin@example.com${NC}"
        echo -e "${YELLOW}默认密码: changeme${NC}"
    else
        echo -e "${RED}安装失败。请检查端口 80/81/443 是否被占用。${NC}"
    fi
}

# 3. 卸载 NPM
uninstall_npm() {
    read -p "确定要彻底卸载 NPM 并删除所有数据吗? (y/n): " confirm
    if [ "$confirm" == "y" ]; then
        echo -e "${YELLOW}正在停止并清理 NPM 容器...${NC}"
        if [ -d "/opt/npm" ]; then
            cd /opt/npm && docker compose down
            cd / && rm -rf /opt/npm
            echo -e "${GREEN}NPM 已成功卸载，/opt/npm 目录已删除。${NC}"
        else
            echo -e "${RED}未发现安装目录 /opt/npm。${NC}"
        fi
    fi
}

# 4. 卸载 Docker
uninstall_docker() {
    read -p "确定要彻底卸载 Docker 环境吗? (y/n): " confirm
    if [ "$confirm" == "y" ]; then
        echo -e "${YELLOW}正在卸载 Docker 相关组件...${NC}"
        if [ -f /etc/debian_version ]; then
            apt-get purge -y docker-ce docker-ce-cli containerd.io && apt-get autoremove -y
        else
            yum remove -y docker-ce docker-ce-cli containerd.io
        fi
        echo -e "${GREEN}Docker 卸载操作已完成。${NC}"
    fi
}

# --- 脚本执行入口 ---

while true; do
    show_menu
    case $choice in
        1) install_docker ;;
        2) install_npm ;;
        3) uninstall_npm ;;
        4) uninstall_docker ;;
        0) exit 0 ;;
        *) echo -e "${RED}无效选项，请重新输入！${NC}" ;;
    esac
    read -p "按回车键返回主菜单..."
done
