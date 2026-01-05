#!/bin/bash

# ==========================================
# 项目: Nginx Proxy Manager 一键安装脚本
# 作者: Facker668
# ==========================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}==================================================${NC}"
echo -e "${CYAN}       Nginx Proxy Manager 一键安装工具           ${NC}"
echo -e "${CYAN}               作者: Facker668                    ${NC}"
echo -e "${CYAN}==================================================${NC}"
echo -e "${YELLOW}[免责声明]${NC}"
echo -e "1. 本脚本仅供学习和研究使用，作者不对使用本脚本造成的"
echo -e "   任何数据丢失、系统故障或安全问题负责。"
echo -e "2. 运行此脚本即表示您同意以上条款。"
echo -e "${CYAN}==================================================${NC}"
read -p "是否继续安装? (y/n): " confirm
if [ "$confirm" != "y" ]; then
    echo -e "${RED}安装已取消。${NC}"
    exit 1
fi

# 1. 检查 Root 权限
echo -e "\n${YELLOW}[步骤 1/6] 权限检查...${NC}"
if [ "$EUID" -ne 0 ]; then 
  echo -e "${RED}错误：请使用 root 用户运行。${NC}"
  exit 1
fi
echo -e "${GREEN}权限检查通过！${NC}"

# 2. 系统环境检测
echo -e "\n${YELLOW}[步骤 2/6] 系统环境检测...${NC}"
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    echo -e "${GREEN}检测到系统: $NAME${NC}"
else
    echo -e "${RED}无法识别系统版本。${NC}"
    exit 1
fi

# 3. 安装基础依赖
echo -e "\n${YELLOW}[步骤 3/6] 安装依赖 (curl, wget)...${NC}"
if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
    apt-get update -y && apt-get install -y curl wget
else
    yum install -y curl wget
fi

# 4. Docker 环境检查与安装
echo -e "\n${YELLOW}[步骤 4/6] 检查 Docker 环境...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${CYAN}正在安装 Docker...${NC}"
    curl -fsSL https://get.docker.com | sh
    systemctl enable --now docker
else
    echo -e "${GREEN}Docker 已存在，跳过安装。${NC}"
fi

# 5. 配置工作目录
echo -e "\n${YELLOW}[步骤 5/6] 准备配置文件...${NC}"
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
echo -e "${GREEN}配置文件已生成在 /opt/npm${NC}"

# 6. 启动服务
echo -e "\n${YELLOW}[步骤 6/6] 启动 Nginx Proxy Manager...${NC}"
docker compose up -d

if [ $? -eq 0 ]; then
    IP=$(curl -s ifconfig.me)
echo -e "\n${CYAN}==================================================${NC}"
    echo -e "${GREEN}        🎉 恭喜！Nginx Proxy Manager 安装成功！${NC}"
    echo -e "${CYAN}==================================================${NC}"
    echo -e "作者: ${YELLOW}Facker668${NC}"
    echo -e "管理地址: ${GREEN}http://${IP}:81${NC}"
    echo -e "${YELLOW}首次登录提示：${NC}"
    echo -e "新版本 NPM 请直接在网页前端创建您的管理员账号、邮箱和密码。"
    echo -e "${CYAN}==================================================${NC}"
else
    echo -e "${RED}启动失败，请检查 Docker 日志。${NC}"
fi
