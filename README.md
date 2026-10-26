# 1Panel 第三方应用商店

适用于 1Panel 本地应用机制的社区应用模板集合。通过同步脚本将本仓库中的模板复制到本地应用目录，再在面板中刷新本地应用列表即可安装。

本项目是独立第三方项目，与 1Panel 官方无隶属关系。应用镜像、名称和图标归各自上游所有；各应用说明中保留了上游链接。

## 应用列表

| 应用 | 模板版本 | 用途 |
| --- | --- | --- |
| [Clash Meta](clash-meta/README.md) | 1.19.31 | mihomo 代理与 metacubexd 面板 |
| [Docker Proxy](docker-proxy/README.md) | latest | Docker 镜像加速与管理 |
| [Magpie](magpie/README.md) | latest | AI 模型网关与订阅管理 |
| [Radicale](radicale/README.md) | 3.0.0 | CalDAV 日历与 CardDAV 通讯录 |
| [Sakura Frp](sakura-frp/README.md) | 1.0.0 | 内网穿透 |

表中的版本是模板目录名；实际镜像标签以对应 `docker-compose.yml` 为准。`latest`、`stable` 等可变标签不保证镜像内容不变。

## 环境与路径

- Linux、Bash、curl、tar、`flock`（通常由 util-linux 提供）及 GNU coreutils、diffutils、findutils。
- 已安装 1Panel 和 Docker，服务器能访问 GitHub 以及各应用的镜像仓库。
- 默认模板目录：`/opt/1panel/resource/apps/local`。自定义安装位置时，请修改下方的 `LOCAL_APPS_DIR`，以当前面板实际目录为准。
- 使用有权写入模板目录的账户执行；计划任务通常使用 root。
- 多数应用使用 `1panel-network`，安装前可用 `docker network inspect 1panel-network` 检查网络。

本仓库使用本地应用导入方式，无需填写官方商店源地址。结构依据 [1Panel 官方本地应用实现](https://github.com/1Panel-dev/1Panel/blob/19707a68dd554c72b5ff96d22f833d76af31efa2/agent/app/service/app_utils.go)。

## 首次安装

在服务器终端执行以下脚本。它下载当前 `main` 分支的源码压缩包，验证压缩包结构后同步应用。下载最多重试，并依次尝试 GitHub 的源码下载入口，避免因为一次 `git clone` TLS 中断而直接退出。

```bash
curl --fail --location --http1.1 --connect-timeout 20 --max-time 180 \
  --proto '=https' --proto-redir '=https' \
  https://raw.githubusercontent.com/shenbourne/1panel-appstore/main/scripts/install.sh |
  STORE_DIR=/opt/1panel-third-party/shenbourne \
  LOCAL_APPS_DIR=/opt/1panel/resource/apps/local \
  bash
```

执行成功后，在 1Panel 的「应用商店 → 本地应用」中执行刷新或同步本地应用操作，再选择应用安装；不同版本的按钮名称可能不同。脚本只同步模板文件，不调用面板 API，不自动安装或升级容器。定时同步后如界面仍显示旧内容，请再次刷新本地应用。

如果服务器直连 GitHub 不稳定，可参考 [arch3rPro/1Panel-Appstore](https://github.com/arch3rPro/1Panel-Appstore) 的做法，在上面的 `bash` 前添加代理变量：

```bash
DOWNLOAD_PROXY=https://ghfast.top/ bash
```

即完整命令最后三行改为：

```bash
  STORE_DIR=/opt/1panel-third-party/shenbourne \
  LOCAL_APPS_DIR=/opt/1panel/resource/apps/local \
  DOWNLOAD_PROXY=https://ghfast.top/ bash
```

`ghfast.top` 是第三方服务，不由本项目或 GitHub 运营；是否使用由管理员自行决定。脚本仍要求 HTTPS 并保留证书校验，不建议用 `GIT_SSL_NO_VERIFY` 或 `curl -k` 绕过 TLS 验证。注意：上述代理只接管源码压缩包下载，最前面的 `raw.githubusercontent.com` 启动脚本仍需能访问；如果该域名也不可达，可先手动下载 `scripts/install.sh` 后执行。

## 添加到 1Panel 计划任务

1. 登录 1Panel，打开「计划任务」，新建任务。
2. 任务类型选择「Shell 脚本」，名称填写 `同步第三方应用商店`。
3. 执行周期选择每天一次，例如每天凌晨 03:15；时间以服务器/面板设置为准。
4. 将「首次安装」中的完整脚本粘贴到脚本内容，按实际安装位置调整 `LOCAL_APPS_DIR`。
5. 保存并手动执行一次，在任务报告中确认出现 `Templates ready`，且没有 `ERROR` 或 Git 错误。
6. 回到「应用商店 → 本地应用」刷新列表，确认五个应用可以显示。

保留完整脚本可以让每次任务执行时连同步脚本自身一起更新。首次执行也可以直接在计划任务中完成。下载和同步阶段均有文件锁，不要同时创建多条相同任务。

如果服务器缺少 curl、tar、`flock`、`diff` 或 `find`，请通过系统包管理器安装上文列出的对应依赖。

## 同步行为与备份

- 仅同步 `apps.txt` 中的应用目录，其他本地商店的应用不受影响。
- 更新同名模板前备份至 `/opt/1panel-third-party/shenbourne/backups/<时间>-<随机后缀>/`。
- 保留目标中的额外文件，不自动清理旧版本目录；移除版本需要管理员检查后手动处理。
- 只更新应用模板，不修改已安装实例的配置、容器和数据卷。已有实例升级需在面板中单独操作。
- 同名本地模板会被覆盖，请先确认是否已有自定义修改；备份不会自动删除，需自行定期整理。

回滚时先暂停计划任务，将所需备份中的应用目录复制回实际本地应用目录，再刷新本地应用。此操作回滚模板，不回滚已升级的容器或应用数据。

## 手动导入与卸载

也可下载仓库，将 `apps.txt` 所列的整个应用目录复制到本地应用目录。不要把仓库根目录、`scripts` 或 `_specs` 复制为应用。

停止同步时禁用或删除计划任务。要移除商店模板，先备份，再仅移除本仓库对应的模板目录，并刷新本地应用；已安装应用请通过面板单独管理。

## 目录结构与贡献

```text
apps.txt
scripts/sync.sh
scripts/install.sh
应用标识/
  data.yml
  logo.png
  README.md
  README_en.md
  版本/
    data.yml
    docker-compose.yml
```

新增应用时，提供应用元数据、PNG 图标、中英文说明以及版本参数和 Compose 文件，并把目录名加入 `apps.txt`。禁止提交真实密钥、订阅地址、账户或运行数据。`_specs` 和本地 ZIP 导出文件不发布。

## 验证范围

GitHub Actions 检查 YAML、目录结构和脚本，并在 Linux 临时目录验证下载器、同步、备份、重复执行、保留其他商店及拒绝符号链接。也可在 Linux 上手动运行 `bash tests/sync.sh`。真实 1Panel 导入、各应用容器启动和计划任务执行仍需在服务器上确认。
