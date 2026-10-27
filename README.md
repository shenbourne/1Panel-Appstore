<h1 align="center">Shenbourne · 1Panel Appstore</h1>

<p align="center">自托管服务，从应用商店开始。<br>为 1Panel 整理的第三方 Docker 应用模板。</p>

<p align="center">
  <a href="https://github.com/shenbourne/1Panel-Appstore/actions/workflows/validate.yml"><img src="https://github.com/shenbourne/1Panel-Appstore/actions/workflows/validate.yml/badge.svg" alt="应用校验"></a>
  <img src="https://img.shields.io/badge/1Panel-Local%20Apps-2563eb" alt="1Panel 本地应用">
  <img src="https://img.shields.io/badge/Apps-8-0f766e" alt="8 个应用">
</p>

<p align="center"><a href="#应用一览">应用一览</a> · <a href="#添加到-1panel-计划任务">计划任务</a> · <a href="#网络与加速">网络与加速</a> · <a href="CONTRIBUTING.md">贡献应用</a></p>

---

## 简介

收录实用的自托管应用，通过计划任务导入 1Panel，在本地应用商店中选择安装。每个应用提供独立的使用说明，方便查看配置与部署方法。

## 应用一览

<table width="100%">
<tr>
<td align="center" valign="top" width="33%"><a href="apps/clash-meta/README.md"><img src="apps/clash-meta/logo.png" height="64" alt="Clash Meta"><br><strong>Clash Meta</strong></a><br>规则代理与流量分流<br>可视化管理节点与分流<br><code>1.19.31</code> · <a href="https://wiki.metacubex.one">官网</a></td>
<td align="center" valign="top" width="33%"><a href="apps/docker-proxy/README.md"><img src="apps/docker-proxy/logo.png" height="64" alt="Docker Proxy"><br><strong>Docker Proxy</strong></a><br>自建 Docker 镜像加速<br>可视化管理代理与转发<br><code>latest</code> · <a href="https://dqzboy.github.io/docs/">官网</a></td>
<td align="center" valign="top" width="33%"><a href="apps/magpie/README.md"><img src="apps/magpie/logo.png" height="64" alt="Magpie"><br><strong>Magpie</strong></a><br>统一管理 AI 模型与订阅<br>集中配置网关与模型路由<br><code>latest</code> · <a href="https://usemagpie.ai">官网</a></td>
</tr>
<tr>
<td align="center" valign="top" width="33%"><a href="apps/radicale/README.md"><img src="apps/radicale/logo.png" height="64" alt="Radicale"><br><strong>Radicale</strong></a><br>自托管日历与通讯录<br>支持标准协议与多端同步<br><code>3.0.0</code> · <a href="https://radicale.org/v3.html">官网</a></td>
<td align="center" valign="top" width="33%"><a href="apps/sakura-frp/README.md"><img src="apps/sakura-frp/logo.png" height="64" alt="Sakura Frp"><br><strong>Sakura Frp</strong></a><br>内网穿透与远程访问<br>通过启动器统一管理隧道<br><code>1.0.0</code> · <a href="https://www.natfrp.com">官网</a></td>
<td align="center" valign="top" width="33%"><a href="apps/nav-site/README.md"><img src="apps/nav-site/logo.png" height="64" alt="Nav-Site"><br><strong>Nav-Site</strong></a><br>自托管导航与书签管理<br>集中整理常用网站与链接<br><code>latest</code> · <a href="https://github.com/shenbourne/Nav-Site">官网</a></td>
</tr>
<tr>
<td align="center" valign="top" width="33%"><a href="apps/clash-configurator/README.md"><img src="apps/clash-configurator/logo.png" height="64" alt="Clash-Configurator"><br><strong>Clash-Configurator</strong></a><br>可视化编辑代理配置<br>管理节点、分组与规则集<br><code>latest</code> · <a href="https://github.com/shenbourne/Clash-Configurator">官网</a></td>
<td align="center" valign="top" width="33%"><a href="apps/tool-nest/README.md"><img src="apps/tool-nest/logo.png" height="64" alt="Tool-Nest"><br><strong>Tool-Nest</strong></a><br>一站式开发与日常工具<br>处理文本、图片与数据<br><code>latest</code> · <a href="https://github.com/shenbourne/Tool-Nest">官网</a></td>
<td align="center" valign="top" width="33%"><a href="https://github.com/shenbourne/1Panel-Appstore/issues"><strong>推荐下一个应用</strong></a><br>分享实用的自托管服务<br>提交应用来源与部署需求</td>
</tr>
</table>

## 使用前准备

已安装 1Panel、Docker 和 Python 3。默认本地应用目录为 `/opt/1panel/resource/apps/local`，自定义安装路径时请修改脚本中的 `LOCAL_APPS_DIR`。

## 添加到 1Panel 计划任务

1. 打开 1Panel「计划任务」，新增任务，类型选择 **Shell 脚本**。
2. 名称填写 `同步 Shenbourne 应用商店`，周期可设为每天一次，例如 03:15，以面板/服务器时区为准。
3. 将下面计划任务脚本粘贴到脚本框。自定义安装路径时修改 `LOCAL_APPS_DIR`；网络加速配置见下一节。
4. 保存并手动执行一次，查看任务报告，确认出现 `Templates ready`。
5. 打开「应用商店 → 本地应用」，执行刷新或同步本地应用，然后选择应用安装。不同面板版本的按钮名称可能不同。

<details open>
<summary><strong>计划任务脚本（也可直接在服务器终端执行）</strong></summary>

```bash
#!/usr/bin/env bash
set -euo pipefail

# 自定义 1Panel 安装位置时修改此路径。
export LOCAL_APPS_DIR="/opt/1panel/resource/apps/local"
# 可替换为其他加速地址；留空则直连。
export DOWNLOAD_PROXY="https://ghfast.top/"

script_url="${DOWNLOAD_PROXY:+${DOWNLOAD_PROXY%/}/}https://github.com/shenbourne/1Panel-Appstore/raw/refs/heads/main/scripts/download.sh"
script="$(curl -fsSL --connect-timeout 20 --max-time 180 "$script_url")"
test -n "$script"
bash -n <<< "$script"
bash -c "$script"
```

</details>

## 网络与加速

脚本默认使用 GH Fast 下载加速。如需切换，可替换计划任务脚本中的配置：

```bash
# 用此行替换计划任务脚本中的 DOWNLOAD_PROXY 配置；地址可从下表选择。
export DOWNLOAD_PROXY="https://ghfast.top/"
```

也可以选择以下任意一个地址：

| GitHub 下载加速 | `DOWNLOAD_PROXY` 填写值 |
| --- | --- |
| GH Fast | `https://ghfast.top/` |
| GH-Proxy | `https://gh-proxy.com/` |
| GH-Proxy.org | `https://gh-proxy.org/` |

选择一个地址，替换计划任务脚本中的 `export DOWNLOAD_PROXY=...` 一行，保存后重新执行任务。直连 GitHub 超时（`curl: (28) Connection timed out`）时，建议先启用上述加速地址；仍失败时换另一个地址。

如需直连 GitHub，将配置改为 `export DOWNLOAD_PROXY=""`。已有计划任务需重新粘贴上面的计划任务脚本，仓库更新不会自动修改面板中保存的任务内容。

以上均为第三方服务，可用性因网络而异。加速服务需支持 `代理前缀/https://github.com/...` 格式，并且能同时下载安装脚本和应用压缩包。

## 手动导入与停止同步

下载源码压缩包后，把 `apps/` 下需要的**应用目录**复制到本地应用目录，再刷新本地应用。不要把 `apps` 本身、仓库根目录或 `scripts` 当成应用导入。

停止同步只需禁用或删除计划任务。移除模板前请先备份，再移除本仓库对应目录；已安装实例通过面板单独管理。

## 合并重复应用

计划任务在每次同步模板后自动合并重复应用，无需添加额外任务。需要单独检查时，可在仓库目录执行：

```bash
# 先预览；自定义安装位置时，修改 --local-apps-dir。
python3 scripts/merge-duplicates.py --local-apps-dir /opt/1panel/resource/apps/local

# 确认预览结果后执行合并，完成后刷新面板中的本地应用列表。
python3 scripts/merge-duplicates.py --local-apps-dir /opt/1panel/resource/apps/local --apply
```

脚本比较所有版本的 `docker-compose.yml`，版本目录和文件内容全部相同才视为重复（忽略 Windows/Linux 换行符差异）。同名应用不是判断依据；仅镜像相同、端口不同或多出版本均不会合并。表单、挂载文件或其他附加文件有冲突时跳过。

合并保留本仓库的应用标识、图标和说明，补入缺少的文件，先备份双方目录，再移除重复模板目录。计划任务备份位于 `STORE_DIR/backups/merge-*`，默认路径为 `/opt/1panel-third-party/shenbourne/backups/merge-*`。独立执行可用 `--backup-dir` 修改。执行时避免与其他商店同步任务重叠；本脚本不修改已安装容器和数据卷。

## 贡献与反馈

欢迎通过 [Issues](https://github.com/shenbourne/1Panel-Appstore/issues) 推荐应用或反馈问题，也可以提交 PR 添加应用。应用包要求和维护说明见 [贡献指南](CONTRIBUTING.md)。
