<h1 align="center">Shenbourne · 1Panel Appstore</h1>

<p align="center">自托管服务，从应用商店开始。<br>为 1Panel 整理的第三方 Docker 应用模板。</p>

<p align="center">
  <a href="https://github.com/shenbourne/1panel-appstore/actions/workflows/validate.yml"><img src="https://github.com/shenbourne/1panel-appstore/actions/workflows/validate.yml/badge.svg" alt="应用校验"></a>
  <img src="https://img.shields.io/badge/1Panel-Local%20Apps-2563eb" alt="1Panel 本地应用">
  <img src="https://img.shields.io/badge/Apps-5-0f766e" alt="5 个应用">
</p>

<p align="center"><a href="#应用一览">应用一览</a> · <a href="#添加到-1panel-计划任务">计划任务</a> · <a href="#网络与加速">网络与加速</a> · <a href="#目录与规范">目录规范</a> · <a href="CONTRIBUTING.md">贡献应用</a></p>

---

## 关于商店

本仓库遵循 [1Panel 官方应用商店](https://github.com/1Panel-dev/appstore) 的应用包结构，将应用集中放在 `apps/` 中，并提供本地应用导入脚本。仓库首页的组织方式参考 [okxlin/appstore](https://github.com/okxlin/appstore) 和 [arch3rPro/1Panel-Appstore](https://github.com/arch3rPro/1Panel-Appstore)。

- **集中管理**：应用元数据、安装表单、Compose 和使用说明随模板一起维护。
- **自动同步**：通过 1Panel Shell 计划任务下载并导入模板，支持重试和可选下载代理。
- **备份可查**：覆盖同名模板前保存备份，保留其他商店的应用和目标目录中的额外文件。

这是独立第三方项目，与 1Panel 官方无隶属关系。只同步模板文件；安装、容器升级和数据备份仍由管理员在面板中操作。

## 应用一览

<table>
<tr>
<td align="center" width="33%"><a href="apps/clash-meta/README.md"><img src="apps/clash-meta/logo.png" height="64" alt="Clash Meta"><br><strong>Clash Meta</strong></a><br>mihomo 代理与 metacubexd 面板<br><code>1.19.31</code></td>
<td align="center" width="33%"><a href="apps/docker-proxy/README.md"><img src="apps/docker-proxy/logo.png" height="64" alt="Docker Proxy"><br><strong>Docker Proxy</strong></a><br>Docker 镜像加速与管理<br><code>latest</code></td>
<td align="center" width="33%"><a href="apps/magpie/README.md"><img src="apps/magpie/logo.png" height="64" alt="Magpie"><br><strong>Magpie</strong></a><br>AI 模型网关与订阅管理<br><code>latest</code></td>
</tr>
<tr>
<td align="center"><a href="apps/radicale/README.md"><img src="apps/radicale/logo.png" height="64" alt="Radicale"><br><strong>Radicale</strong></a><br>CalDAV 日历与 CardDAV 通讯录<br><code>3.0.0</code></td>
<td align="center"><a href="apps/sakura-frp/README.md"><img src="apps/sakura-frp/logo.png" height="64" alt="Sakura Frp"><br><strong>Sakura Frp</strong></a><br>内网穿透与远程访问<br><code>1.0.0</code></td>
<td align="center"><a href="https://github.com/shenbourne/1panel-appstore/issues"><strong>推荐下一个应用</strong></a><br>提交应用来源与部署需求</td>
</tr>
</table>

版本是模板目录名，实际镜像以对应 `docker-compose.yml` 为准。`latest`、`stable` 等标签的镜像内容会随上游变化；模板版本不代表已锁定镜像版本。

## 使用前准备

服务器需安装 1Panel 和 Docker，并具备 Bash、curl、tar、`flock`（通常来自 util-linux）、coreutils、diffutils、findutils 和 grep。压缩包导入不依赖 Git。

默认模板目录为 `/opt/1panel/resource/apps/local`；自定义安装路径时，修改脚本中的 `LOCAL_APPS_DIR`。使用有权写入目录的账户执行。需要 `1panel-network` 的应用可先通过 `docker network inspect 1panel-network` 检查网络。

## 添加到 1Panel 计划任务

1. 打开 1Panel「计划任务」，新增任务，类型选择 **Shell 脚本**。
2. 名称填写 `同步 Shenbourne 应用商店`，周期可设为每天一次，例如 03:15，以面板/服务器时区为准。
3. 将下面完整脚本粘贴到脚本框。自定义安装路径时修改 `LOCAL_APPS_DIR`；网络加速配置见下一节。
4. 保存并手动执行一次，查看任务报告，确认出现 `Templates ready`。
5. 打开「应用商店 → 本地应用」，执行刷新或同步本地应用，然后选择应用安装。不同面板版本的按钮名称可能不同。

<details open>
<summary><strong>展开计划任务完整脚本（也可直接在服务器终端执行）</strong></summary>

```bash
#!/usr/bin/env bash
set -Eeuo pipefail
export STORE_DIR="${STORE_DIR:-/opt/1panel-third-party/shenbourne}"
export LOCAL_APPS_DIR="${LOCAL_APPS_DIR:-/opt/1panel/resource/apps/local}"
export DOWNLOAD_PROXY="${DOWNLOAD_PROXY:-}"

urls=(
  "https://raw.githubusercontent.com/shenbourne/1panel-appstore/main/scripts/install.sh"
  "https://github.com/shenbourne/1panel-appstore/raw/refs/heads/main/scripts/install.sh"
)
if [[ -n "$DOWNLOAD_PROXY" ]]; then
  [[ "$DOWNLOAD_PROXY" = https://* ]] || { echo "DOWNLOAD_PROXY must use HTTPS" >&2; exit 1; }
  urls=("${DOWNLOAD_PROXY%/}/${urls[1]}")
fi
script="$(mktemp)"
trap 'rm -f -- "$script"' EXIT
for url in "${urls[@]}"; do
  for attempt in 1 2 3; do
    if curl --fail --location --http1.1 --connect-timeout 20 --max-time 180 \
      --proto '=https' --proto-redir '=https' --output "$script" "$url" &&
      [[ -s "$script" ]] && bash -n "$script"; then
      bash "$script"
      exit 0
    fi
    echo "Bootstrap download failed (attempt $attempt/3)" >&2
    sleep 2
  done
done
echo "Cannot download installer. Check network or DOWNLOAD_PROXY; templates unchanged." >&2
exit 1
```

</details>

启动脚本先下载到临时文件，下载成功且语法检查通过后才执行；失败会返回非零状态。安装器再下载源码压缩包，验证归档结构并同步 `apps/` 中的模板。整个流程保留 TLS 校验，并分别锁定下载和同步阶段。

每次任务都会读取最新脚本与 `main` 分支模板。同步不会自动刷新面板数据库；若界面未更新，请手动刷新本地应用，也不会自动升级已安装容器。

## 网络与加速

遇到 `GnuTLS recv error (-110)`、TLS 中断或 GitHub 连接超时时，先检查服务器网络、DNS 和代理。本仓库默认使用压缩包下载，启动脚本和源码下载均有重试及官方备用入口，不再要求计划任务执行 `git clone`。

如果需要使用可信的 GitHub 下载代理，在计划任务脚本开头把代理变量这一行改为：

```bash
export DOWNLOAD_PROXY="https://你的代理地址/"
```

代理需支持 `代理前缀/https://github.com/...` 形式。配置后，**启动脚本与源码压缩包均走同一代理**。例如参考商店使用过 `https://ghfast.top/`；它属于第三方服务，本项目不保证其当前可用性或内容完整性，请自行选择可信服务。不要关闭 TLS 证书验证。

旧的 `curl ... | bash` 或 Git 克隆任务请替换为上面的完整脚本；旧任务文本不会随仓库更新自动改变。此前创建的 `bootstrap` Git 目录不再用于新流程，无需为迁移删除它。

## 同步、备份与回滚

| 行为 | 说明 |
| --- | --- |
| 导入范围 | 仅导入 `apps.txt` 列出的 `apps/<应用标识>/` |
| 备份位置 | `STORE_DIR/backups/<时间>-<随机后缀>/` |
| 同名模板 | 覆盖前备份，避免丢失本地自定义内容 |
| 其他商店 | 保留其他应用目录 |
| 额外文件与旧版本 | 保留，不自动清理 |
| 已安装实例 | 不修改容器、运行配置和数据卷 |

默认 `STORE_DIR` 为 `/opt/1panel-third-party/shenbourne`。备份由管理员定期整理。下载或校验失败时不会导入模板；复制期间发生磁盘或权限错误可能留下部分更新，应根据任务日志和备份恢复。

回滚模板前暂停计划任务，再把备份中的对应应用目录复制回实际本地应用目录并刷新本地应用。模板回滚不会回滚已升级容器或业务数据。

## 手动导入与停止同步

下载源码压缩包后，把 `apps/` 下需要的**应用目录**复制到本地应用目录，再刷新本地应用。不要把 `apps` 本身、仓库根目录或 `scripts` 当成应用导入。

停止同步只需禁用或删除计划任务。移除模板前请先备份，再移除本仓库对应目录；已安装实例通过面板单独管理。

## 目录与规范

```text
.
├── apps/                       # 可导入的应用模板
│   └── <app-key>/
│       ├── data.yml            # additionalProperties 应用元数据
│       ├── logo.png
│       ├── README.md
│       ├── README_en.md
│       └── <version>/          # 版本号不加 v 前缀
│           ├── data.yml        # additionalProperties.formFields
│           ├── docker-compose.yml
│           └── data/           # 可选挂载文件
├── data.yaml                   # 商店分类和目录版本
├── apps.txt                    # 本仓库同步脚本使用的应用清单
├── scripts/                    # 下载、同步与规范检查
├── tests/                      # 导入与下载回归验证
└── .github/workflows/          # GitHub Actions
```

`apps.txt` 是本仓库同步工具的清单，不是官方要求的应用包文件。根目录 `data.yaml` 用于描述商店分类，脚本只导入应用目录，不覆盖 1Panel 官方商店的元数据，也不将本仓库宣称为官方商店接口。

贡献应用前请阅读 [贡献指南](CONTRIBUTING.md)，并运行：

```bash
python -m pip install PyYAML==6.0.3
python scripts/validate.py
bash tests/sync.sh
```

自动检查覆盖目录、元数据、中英文安装表单、Compose 变量与参数对应关系，以及下载、备份和导入行为。真实 1Panel 导入、计划任务和各应用启动仍需在服务器上验证。

## 参考与反馈

- [1Panel 官方应用商店](https://github.com/1Panel-dev/appstore) · [应用提交规范](https://github.com/1Panel-dev/appstore/wiki/How-to-submit-your-own-application)
- [okxlin/appstore](https://github.com/okxlin/appstore) · [arch3rPro/1Panel-Appstore](https://github.com/arch3rPro/1Panel-Appstore)
- [提交问题或应用建议](https://github.com/shenbourne/1panel-appstore/issues)

应用名称、图标和容器镜像归各自上游所有，请遵循上游许可证与使用条款。应用配置中的权限、端口和数据目录应在安装前按实际环境确认。
