# Tool-Nest · 1Panel 本地应用

支持中英文的开发与日常工具工作台，包含文本、数据转换、图片、PDF、音视频与网络诊断工具。部分功能需要联网下载资源或访问外部服务。

## 镜像与环境

- 上游项目：<https://github.com/shenbourne/Tool-Nest>
- 镜像：`shenbourne/tool-nest:latest`（Docker Hub）
- 镜像架构：amd64 / arm64，按发布时 Docker Hub 的 `latest` 清单核对；不包含证明用的 `unknown/unknown` 清单。
- 容器内端口：`3000`；默认主机端口：`8080`。
- 依赖 Docker 外部网络 `1panel-network`，缺少时先创建。

`latest` 为可变标签，模板不会锁定镜像内容。升级前请备份并检查上游变更。

## 安装与访问

同步商店后在 1Panel 本地应用中刷新并安装。安装表单中可调整 `PANEL_APP_PORT_HTTP` 和 `APP_BIND_IP`。

默认保持上游的本机访问边界，监听 `127.0.0.1:8080`。通过服务器本机或带访问控制的 1Panel 反向代理访问。需要可信局域网访问时调整 `APP_BIND_IP`。

`CORS_ORIGIN` 默认 `http://localhost:8080`，请填浏览器实际访问地址（含协议和端口，不带路径），例如 `https://tools.example.com`。更改端口或域名时同步更新该值。应用未提供登录认证，CORS 不能代替访问控制，不要直接公开写入 API。

## 持久化与备份

使用 Docker 命名卷 `toolnest-data` 挂载 `/app/data`，保存收藏、偏好和报告等状态。采用命名卷保留镜像中非 root 用户的数据目录权限。实际卷名带 Compose 项目前缀，请通过 `docker volume ls` 确认。

停止应用后备份该卷。卸载时不要勾选删除数据卷，除非已有备份；不要执行 `docker compose down -v` 作为日常停止命令。

## 浏览器要求

建议通过 HTTPS 反向代理访问。部分浏览器工具需要安全上下文，普通局域网 HTTP 入口可能无法使用全部功能；本模板未注入 fnOS 包中的 HTTP 兼容层。

## 验证范围

已检查上游部署配置、已发布镜像架构、模板结构、安装表单与 Compose 变量；真实 1Panel 安装、镜像拉取与功能运行仍需在目标服务器确认。
