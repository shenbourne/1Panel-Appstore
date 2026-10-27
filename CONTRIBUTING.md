# 贡献应用

## 应用包格式

以 [1Panel 官方应用提交规范](https://github.com/1Panel-dev/appstore/wiki/How-to-submit-your-own-application) 和 [官方仓库](https://github.com/1Panel-dev/appstore) 为依据。当前结构参考官方提交 `79cf43943621005b36ea16c0a134feef27a29cec`，规范更新时需重新核对。

1. 应用放在 `apps/<app-key>/` 中，目录标识使用小写英文、数字和连字符，并与 `additionalProperties.key` 一致。
2. 应用根目录提供 `data.yml`、`logo.png`、`README.md` 和 `README_en.md`。官方建议图标为 180×180 PNG、尽量小于 10 KB；现有图标不影响导入，优化时应保留可读性及上游标识。
3. 应用元数据使用 `additionalProperties`，填写名称、分类、中英文描述、类型、升级策略、安装数量限制和上游链接。分类必须在根目录 `data.yaml` 中定义。
4. 版本目录不加 `v` 前缀，每个版本提供 `data.yml` 和 `docker-compose.yml`；`data.yml` 必须有 `additionalProperties.formFields`，无参数时使用空列表。
5. 安装表单提供中英文 `label`。外部端口使用 `PANEL_APP_PORT_*`、`type: number`、`rule: paramPort`；Web 入口优先用 `PANEL_APP_PORT_HTTP`。
6. Compose 变量应由表单提供，`CONTAINER_NAME` 由面板注入。每个服务应有 `createdBy: Apps` 标签。需要时使用外部网络 `1panel-network`，挂载文件放在版本目录下。
7. 将应用标识加入 `apps.txt`。这是本仓库同步工具的清单，必须与 `apps/` 的应用目录对应。

`latest` 等可变镜像标签需要在应用说明中注明。不要在迁移目录时顺便更换镜像版本、端口或数据目录；这些行为变化应单独说明和验证。

## 说明与验证

应用说明应包括官方来源、镜像、架构、参数、端口、持久化目录、初始化步骤和备份方式。不提交真实密钥、订阅、用户数据和临时导出文件。

```bash
python -m pip install PyYAML==6.0.3
python scripts/validate.py
bash -n scripts/*.sh tests/*.sh
bash tests/sync.sh
```

提交时说明使用的 1Panel 版本、服务器架构和实际启动结果。尚未验证的部分明确写为“未验证”，不要以静态检查替代真实部署结论。

## 维护同步脚本

`scripts/bootstrap.sh` 是 README 中可复制的短入口，完整下载处理位于远程 `scripts/download.sh`。修改入口时同步更新 README 的脚本，测试会核对两者一致。下载必须保留 HTTPS 和证书校验，并以非零状态报告失败。

同步仅复制 `apps.txt` 列出的模板，不操作已安装实例；不得覆盖其他商店目录或自动删除旧版本。变更目录布局时同时修改同步脚本、下载器、回归测试和 README 链接。

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
