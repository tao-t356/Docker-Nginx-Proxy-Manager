# 🚀 Nginx Proxy Manager 综合管理脚本

[![Author](https://img.shields.io/badge/Author-Facker668-blue.svg)](mailto:tao356334@gmail.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![OS](https://img.shields.io/badge/OS-Ubuntu%20%7C%20Debian%20%7C%20CentOS-orange.svg)]()

一个为 VPS 深度定制的一键管理工具，集成 Docker 安装、NPM 部署及自动化环境清理功能。特别针对 **IPv6-only** 环境进行了网络优化。

---

## 🛠️ 功能特性

* **全自动安装**: 智能识别系统环境，自动安装 Docker 及 Docker Compose。
* **一键部署**: 快速启动 Nginx Proxy Manager 面板，自动配置数据持久化。
* **快捷访问**: 安装后自动配置系统别名，随时输入 `npm` 即可唤出菜单。
* **干净卸载**: 提供彻底卸载选项，一键删除容器、镜像及关联数据目录。
* **IPv6 友好**: 内置 DNS64 解析优化，解决纯 IPv6 环境拉取镜像失败的问题。

---

## 🚀 快速开始

在您的 VPS 终端复制并粘贴以下命令：

```bash
wget -qO n https://raw.githubusercontent.com/tao-t356/Docker-Nginx-Proxy-Manager/main/install.sh && bash n
```
---

## 💡 使用指南

### 1. 快捷菜单
安装完成后，您不再需要运行长命令，只需输入以下字母并回车：
\`\`\`bash
npm
\`\`\`

### 2. 访问面板
* **管理地址**: `http://您的IP:81`
* **初始化**: 首次访问请直接根据页面提示创建管理员账号。



---

## 👤 作者信息

* **作者**: Facker668
* **Email**: [tao356334@gmail.com](mailto:tao356334@gmail.com)
* **项目地址**: [Docker-Nginx-Proxy-Manager](https://github.com/tao-t356/Docker-Nginx-Proxy-Manager)

---
**感谢使用！如果有任何问题，欢迎通过 Email 联系我。**
