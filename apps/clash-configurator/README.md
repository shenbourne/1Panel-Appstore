# Clash-Configurator · 1Panel 本地应用

可视化创建、编辑、导入与导出 Clash 配置，管理节点、代理组、DNS 和规则集。本应用是配置编辑器，不会运行 Clash 代理内核。

## 镜像与环境

- 上游项目：<https://github.com/shenbourne/Clash-Configurator>
- 镜像：`shenbourne/clash-configurator:latest`（Docker Hub）
- 镜像架构：amd64，按发布时 Docker Hub 的 `latest` 清单核对；不包含证明用的 `unknown/unknown` 清单。
- 容器内端口：`3000`；默认主机端口：`3001`。
- 依赖 Docker 外部网络 `1panel-network`，缺少时先创建。

`latest` 为可变标签，模板不会锁定镜像内容。升级前请备份并检查上游变更。

## 安装与访问

同步商店后在 1Panel 本地应用中刷新并安装。安装表单中可调整 `PANEL_APP_PORT_HTTP` 和 `APP_BIND_IP`。

默认仅监听 `127.0.0.1:3001`，可从服务器本机访问，或通过 1Panel 的反向代理开放访问；代理入口应加访问控制。需要局域网直连时，将 `APP_BIND_IP` 改为服务器 IPv4 地址或 `0.0.0.0`。

`CORS_ORIGIN` 默认 `http://localhost:3001`，请改为浏览器实际访问地址，包含协议和端口、不带路径；多个来源用逗号分隔。它不是登录认证，不能保护写入 API。本模板未添加应用本身不具备的登录机制，请使用可信局域网或带认证的反向代理。

## 持久化与备份

- `./data/configs` → `/app/server/data/configs`：配置文件。
- `./data/rule-sets` → `/app/server/data/rule-sets`：规则集。
- `./data/temp` → `/app/server/data/temp`：临时文件。

停止应用后备份安装目录中的 `data` 目录。配置中可能含节点凭据，备份应妥善保管。

## 图标来源

上游仓库暂无可复用的应用图标，当前 `logo.png` 使用项目作者 GitHub 公开头像作为暂用标识，不代表 mihomo 内核图标。

## 验证范围

已检查上游部署配置、已发布镜像架构、模板结构、安装表单与 Compose 变量；真实 1Panel 安装、镜像拉取与功能运行仍需在目标服务器确认。
