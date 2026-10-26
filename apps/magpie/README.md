# Magpie 1Panel 本地应用

本应用使用官方 Docker 镜像 `ghcr.io/yetone/magpie:latest`，以容器网关模式运行 Magpie。官方文档：<https://usemagpie.ai/docs/docker>。

## 环境要求

- 已安装 1Panel 和 Docker。
- Docker 外部网络 `1panel-network` 已存在。不存在时可执行 `docker network create 1panel-network`。
- 宿主机绑定地址默认是 `0.0.0.0`，可在安装时限制为指定网卡地址；请配合防火墙使用。

## 安装参数

| 参数 | 默认值 | 说明 |
| --- | --- | --- |
| `PANEL_APP_PORT_HTTP` | `3430` | Web UI 的宿主机端口，容器内端口为 `3430` |
| `PANEL_APP_PORT_GATEWAY` | `3425` | API 网关的宿主机端口，容器内端口为 `3425` |
| `MAGPIE_WEB_KEY` | 空（必填） | Web 访问密钥；至少 16 个字符，仅允许字母、数字及 `-`、`.`、`_`、`~` |
| `MAGPIE_BIND_IP` | `0.0.0.0` | 主机监听 IPv4 地址；`127.0.0.1` 仅允许主机访问 |
| `MAGPIE_PUBLIC_URL` | 空（可选） | 通过域名或反向代理访问时填写完整公开地址，例如 `https://magpie.example.com` |

`MAGPIE_WEB_KEY` 在表单中是密码框，默认留空，安装时必须填写。可生成一个兼容的随机密钥：

```bash
openssl rand -hex 24
```

容器启动命令为 `web --addr 0.0.0.0:3430 --no-open`。配置保存在 Docker 命名卷 `magpie-config` 中，并挂载到容器的 `/config`；使用命名卷是为了正确处理容器用户 UID `65532` 的权限。不要随意改成由 root 拥有、UID `65532` 不可写的宿主机目录。

## 导入与安装

1. 将整个 `magpie` 目录复制到 1Panel 的本地应用目录，常见位置是 `/opt/1panel/resource/apps/local`。
2. 在 1Panel 的本地应用页面刷新应用列表。
3. 打开 Magpie，填写端口、`MAGPIE_WEB_KEY`，按需填写 `MAGPIE_PUBLIC_URL`，然后安装。

实际安装根目录可能因 1Panel 版本或部署方式而不同，请以当前面板配置为准。

## 打开 Web UI

安装完成后访问：

```text
http://<服务器地址>:3430/?k=<MAGPIE_WEB_KEY>
```

使用 `https://` 反向代理时，访问公开域名并带上相同的 `?k=` 参数。

## API 网关

先在 Web UI 中创建网关密钥，再使用 API。默认基础地址为：

```text
http://<服务器地址>:3425/v1
```

Web 访问密钥和网关密钥用途不同，请勿混用。UI 的 `3430` 入口也支持 `/v1` 路由；如果已为 UI 配置 HTTPS 反向代理，可统一使用 `https://<域名>/v1`，并避免额外暴露 `3425`。

## 备份与卸载

`magpie-config` 卷保存 Magpie 配置、订阅登录信息和插件等数据。升级或卸载前，请停止应用并备份该卷，可用临时容器打包该卷。实际 Docker 卷名带 Compose 项目前缀，请以 `docker volume ls` 为准。

1Panel 卸载时是否删除数据卷取决于面板版本和所选卸载选项，不能保证保留。不要在没有备份时直接卸载或删除数据卷。

## 订阅与 OAuth

通过 OAuth 添加订阅时，在浏览器完成服务商登录。浏览器跳转到 localhost 后可能无法打开页面，这是因为 localhost 指向你的电脑。复制此时地址栏中的完整回调 URL（包含查询参数），粘贴到 Magpie 登录对话框的 Callback URL 字段。

## 容器模式限制

容器以网关模式运行，不包含桌面/本地版本中的 Agents、Sessions、Library 功能。需要这些本地能力时，请使用对应的本地运行方式。

## HTTPS 与安全

建议通过 HTTPS 反向代理暴露 Web UI。反向代理目标可设为 `http://127.0.0.1:3430`，该入口同时支持 `/v1` 路由。不要把未加密的 HTTP 管理入口或 API 直接暴露到公网，并妥善保管 `MAGPIE_WEB_KEY` 与网关密钥。
