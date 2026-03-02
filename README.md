# 🚀 Docker-Nginx-Proxy-Manager

[![Author](https://img.shields.io/badge/Author-Facker668-blue.svg)](mailto:tao356334@gmail.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![OS](https://img.shields.io/badge/OS-Ubuntu%20%7C%20Debian%20%7C%20CentOS-orange.svg)]()

一个面向 VPS 的 **Nginx Proxy Manager (NPM)** 一键管理脚本：
- 安装 Docker
- 部署/卸载 NPM
- 提供基础安全检查与健康检查

---

## ✨ 功能特性

- **全自动安装 Docker**：未安装时自动拉起 Docker。
- **一键部署 NPM**：自动生成 `docker-compose.yml` 并启动容器。
- **端口占用检查**：安装前检查 `80/81/443`。
- **安装后健康检查**：自动检测 `http://127.0.0.1:81` 可用性。
- **数据持久化**：
  - 数据目录：`/opt/npm/data`
  - 证书目录：`/opt/npm/letsencrypt`
- **安全卸载**：
  - 普通卸载：仅卸载 NPM
  - 危险操作（卸载 Docker）：需输入 `YES_I_KNOW` 二次确认

---

## 🧩 环境要求

- Linux（Ubuntu / Debian / CentOS）
- Root 权限
- 可访问外网（拉取 Docker 镜像）

---

## 🚀 快速开始

```bash
wget -qO n https://raw.githubusercontent.com/tao-t356/Docker-Nginx-Proxy-Manager/main/install.sh && bash n
```

运行后按菜单操作：

1. 安装 Docker 环境
2. 安装 Nginx Proxy Manager
3. 卸载 Nginx Proxy Manager
4. 卸载 Docker 环境（危险）

---

## 🌐 访问面板

- 管理地址：`http://你的服务器IP:81`
- 首次访问：根据页面提示创建管理员账号

> 脚本支持 IPv4/IPv6 地址展示（IPv6 会自动加 `[]`），但**不包含 DNS64 网络改造**。

---

## ⚙️ 可选：指定镜像版本

默认镜像为：`jc21/nginx-proxy-manager:latest`

你可以在运行脚本前指定镜像（推荐固定版本，避免 latest 带来的不确定升级）：

```bash
NPM_IMAGE=jc21/nginx-proxy-manager:2.12.3 bash install.sh
```

---

## 🗑️ 卸载说明

### 仅卸载 NPM（推荐）
会删除 `/opt/npm` 目录及其容器数据。

### 卸载 Docker（高风险）
会影响这台机器上的其他 Docker 项目，脚本会要求输入：

```text
YES_I_KNOW
```

---

## 👤 作者信息

- 作者：Facker668
- Email：tao356334@gmail.com
- 项目地址：https://github.com/tao-t356/Docker-Nginx-Proxy-Manager

---

如果这个项目对你有帮助，欢迎点个 ⭐。