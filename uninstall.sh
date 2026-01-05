#!/bin/bash

# 项目: Nginx Proxy Manager 一键卸载脚本
# 作者: Facker668

RED='\033[0;31m'
NC='\033[0m'

echo -e "${RED}即将开始卸载 Nginx Proxy Manager 及其数据...${NC}"
read -p "此操作不可逆，确认继续? (y/n): " confirm

if [ "$confirm" == "y" ]; then
    # 停止并清理容器
    if [ -d "/opt/npm" ]; then
        cd /opt/npm && docker compose down
        rm -rf /opt/npm
        echo "NPM 数据目录已清理。"
    fi
    
    # 移除快捷别名
    sed -i '/alias npm=/d' ~/.bashrc
    rm -f /usr/local/bin/npm_tool.sh
    
    echo -e "${RED}卸载完成。${NC}"
else
    echo "操作已取消。"
fi
