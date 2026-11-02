# MinerU

将 PDF 等文档解析为 Markdown / JSON，提取文字、表格和公式。本模板启动 Gradio Web 界面。

## 来源与版本

- [官方项目](https://github.com/opendatalab/MinerU) · [官方部署文档](https://opendatalab.github.io/MinerU/quick_start/docker_deployment/)
- 镜像：`windoze/mineru:latest`，由[社区维护者](https://github.com/windoze/mineru-docker)构建，并非官方发布镜像。
- `latest` 是可变标签，重新拉取时可能改变版本。2026-11-02 核验 Docker Hub：标签更新于 2026-08-10；不代表 MinerU 最新软件发行版。官方当前文档采用本地构建 `mineru:4`，本模板不在服务器上自动构建。
- 核验时镜像索引摘要：`sha256:df8535167794a0a6ca30e66f9f4816daf1686e2158b5e33340e3fb0b8d13be90`。
- 架构：Linux amd64 / arm64。镜像内置模型，压缩下载约 13–14 GB，需额外预留解压、运行和文档空间。

## 安装要求与参数

需要 NVIDIA GPU、兼容 CUDA 13.0 的驱动和 NVIDIA Container Toolkit；VLM 后端建议至少 8 GB 可用显存，具体需求随文档和后端变化。本模板要求 GPU，不支持直接在无 GPU 主机安装。

| 参数 | 默认值 | 用途 |
| --- | --- | --- |
| Web 界面端口 | 7860 | 浏览器访问端口 |
| 主机监听地址 | 0.0.0.0 | 所有网卡；可改为 127.0.0.1 供本机反向代理 |
| NVIDIA GPU 编号 | 0 | 分配给容器的单个 GPU 编号 |

安装前在服务器确认 `nvidia-smi` 正常，并配置 Docker 的 NVIDIA GPU 支持。在 1Panel 同步本地应用后安装 MinerU，首次拉取大镜像可能耗时较长。启动后访问 `http://服务器IP:7860`，上传文档并选择解析后端。模型来自镜像内置文件，默认不需要首次下载模型。

该模板只启动 Web 界面，不单独启动 REST API 服务。界面未配置登录认证，访问范围应通过防火墙或带认证的反向代理控制。

## 数据与备份

应用安装目录下 `./data` 挂载到 `/data`，Gradio 临时文件目录为 `/data/gradio`；临时结果可能被 Gradio 清理，重要结果应及时下载。模型位于镜像内，不将空目录挂载到模型路径。停止应用后备份整个 `data` 目录和部署配置；恢复后重新启动。

## 验证状态

已检查上游镜像说明、标签与架构，并通过仓库模板检查；未在 1Panel / NVIDIA GPU 主机实际启动或验证文档解析。图标来源：官方仓库 `docs/images/MinerU-logo.png`，等比缩放到 180×180 画布。
