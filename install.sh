#!/bin/bash

# ==========================================
# 项目: Nginx Proxy Manager 综合管理脚本
# 作者: Facker668
# 邮箱: tao356334@gmail.com
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
  exit 1
fi

# 自动配置别名函数
setup_alias() {
    # 1. 彻底清理之前设置过的冲突别名
    sed -i '/alias npm=/d' ~/.bashrc
    sed -i '/alias n=/d' ~/.bashrc
    
    # 2. 检查并添加新的 f 别名 (仅针对 root 的 .bashrc)
    if ! grep -q "alias f=" ~/.bashrc; then
        cp "$0" /usr/local/bin/npm_tool.sh
        chmod +x /usr/local/bin/npm_tool.sh
        # 写入别名，并在别名命令中再次加入 root 判定，双重保险
        echo "alias f='[ \$(id -u) -eq 0 ] && bash /usr/local/bin/npm_tool.sh || echo \"请使用 root 运行\"'" >> ~/.bashrc
        
        echo -e "${GREEN}快捷命令已配置！${NC}"
        echo -e "${YELLOW}以后只需在 Root 下输入 ${RED}f${YELLOW} 即可打开此菜单。${NC}"
        echo -e "${CYAN}请手动执行一次: ${NC}source ~/.bashrc"
    fi
}

# 菜单主界面
show_menu() {
    clear
    echo -e "${CYAN}==================================================${NC}"
    echo -e "${CYAN}        Nginx Proxy Manager 综合管理脚本           ${NC}"
    echo -e "${CYAN}==================================================${NC}"
    echo -e "${GREEN}  1.${NC} 安装 Docker 环境"
    echo -e "${GREEN}  2.${NC} 安装 Nginx Proxy Manager (NPM)"
    echo -e "${GREEN}  3.${NC} 卸载 Nginx Proxy Manager (NPM)"
    echo -e "${GREEN}  4.${NC} 卸载 Docker 环境"
    echo -e "${RED}  0.${NC} 退出脚本"
    echo -e "${CYAN}==================================================${NC}"
    echo -e "${YELLOW}快捷键提示: 输入 ${RED}f${YELLOW} 即可快速呼出本菜单${NC}"
    echo -e "${CYAN}==================================================${NC}"
    read -p "请输入选项 [0-4]: " choice
}

install_docker() {
    echo -e "\n${YELLOW}正在检查并安装 Docker...${NC}"
    if ! command -v docker &> /dev/null; then
        curl -fsSL https://get.docker.com | sh
        systemctl enable --now docker
        echo -e "${GREEN}Docker 安装完成！${NC}"
    else
        echo -e "${GREEN}Docker 已存在，跳过安装。${NC}"
    fi
    setup_alias
}

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
        echo -e "${GREEN}NPM 安装成功！管理地址: http://${IP}:81${NC}"
    else
        echo -e "${RED}安装失败。${NC}"
    fi
}

uninstall_npm() {
    read -p "确定要彻底卸载 NPM 并删除所有数据吗? (y/n): " confirm
    if [ "$confirm" == "y" ]; then
        echo -e "${YELLOW}正在停止并清理 NPM...${NC}"
        if [ -d "/opt/npm" ]; then
            cd /opt/npm && docker compose down
            cd / && rm -rf /opt/npm
            echo -e "${GREEN}NPM 已成功卸载。${NC}"
        else
            echo -e "${RED}未发现安装目录 /opt/npm。${NC}"
        fi
    fi
}

uninstall_docker() {
    read -p "确定要彻底卸载 Docker 环境并移除快捷命令吗? (y/n): " confirm
    if [ "$confirm" == "y" ]; then
        echo -e "${YELLOW}正在清理环境...${NC}"
        if [ -f /etc/debian_version ]; then
            apt-get purge -y docker-ce docker-ce-cli containerd.io && apt-get autoremove -y
        else
            yum remove -y docker-ce docker-ce-cli containerd.io
        fi
        # 清理所有相关别名
        sed -i '/alias f=/d' ~/.bashrc
        sed -i '/alias n=/d' ~/.bashrc
        sed -i '/alias npm=/d' ~/.bashrc
        rm -f /usr/local/bin/npm_tool.sh
        echo -e "${GREEN}Docker 已卸载，相关配置已清除。${NC}"
    fi
}

# 运行环境检查与配置
setup_alias

# 主循环
while true; do
    show_menu
    case $choice in
        1) install_docker ;;
        2) install_npm ;;
        3) uninstall_npm ;;
        4) uninstall_docker ;;
        0) exit 0 ;;
        *) echo -e "${RED}无效选项！${NC}" ;;
    esac
    read -p "按回车键返回主菜单..."
done
