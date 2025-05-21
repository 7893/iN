# 📦 iN 项目基础设施资源详解 (架构版本 2025年5月21日 - 优雅优先)

> 本文档详细记录 iN 项目在 Vercel、Cloudflare 和 Google Cloud Platform (GCP) 三个平台使用的核心基础设施资源，并提及 GitHub 作为代码管理和 CI/CD 工具。所有资源的目标是尽量利用各服务商的永久免费额度。本文档取代了任何独立的摘要式资源清单。

---
## 概览
本项目采用多云架构，各平台职责如下：
- **Vercel**: 托管和部署前端用户界面。
- **Cloudflare**: 提供边缘网络服务、API网关、分布式**最终/摘要状态协调**及部分边缘优化存储。
- **Google Cloud Platform (GCP)**: 作为核心后端服务平台，提供用户认证、消息队列、核心计算能力、**详细状态/过程数据库**以及集中日志监控。
- **GitHub**: 代码版本控制与CI/CD自动化。
---

## 🎨 Vercel 资源清单 (前端展示平台)

| 类型       | 名称示例 (概念性)          | 说明                                                                 |
| ---------- | -------------------------- | -------------------------------------------------------------------- |
| 项目名称   | `in-frontend`              | Vercel 上的前端项目，例如使用 SvelteKit/Next.js 构建的用户界面。         |
| 部署分支   | `main`, `dev`, `feature/*` | 自动从 GitHub 仓库的相应分支部署到 Vercel 的 Production, Preview 环境。 |
| 环境变量   | `NEXT_PUBLIC_API_GATEWAY_URL`, `NEXT_PUBLIC_GCIP_CONFIG_PARAMS` 等 | 用于前端应用连接后端API和认证服务。通过 Vercel 项目设置管理。             |
| Hobby Plan | N/A                        | 利用 Vercel 的免费 Hobby Plan 提供的构建、部署、CDN 和带宽。            |

---

## ☁️ Cloudflare 资源清单 (边缘网络、API网关、最终/摘要状态协调与边缘存储)

| 类型             | 名称示例 (根据 `naming-conventions-*.md`) | 说明                                                                  |
| ---------------- | --------------------------------------- | --------------------------------------------------------------------- |
| Workers          | `cf-worker-api-gateway-prod`            | API 网关，处理所有入站API请求，路由，认证预处理，发布初始消息到GCP Pub/Sub，与DO交互获取最终/摘要状态。                         |
|                  | `cf-worker-config-api-prod` (如果保留)  | 处理应用或用户特定配置的API（数据可能存储在D1或KV）。                       |
|                  | `cf-worker-image-query-api-prod` (如果保留) | 查询图片任务状态（主要从DO获取）和结果（可能涉及DO或D1）。                 |
| Durable Object   | `cf-do-task-coordinator-prod`           | 任务**最终/摘要状态**协调器，管理每个任务的生命周期高级状态。接收来自GCP流程完成后的低频回调。                               |
| R2 Bucket        | `cf-r2-images-prod-distribution` (可选) | (可选) 存储最终处理完成的、需要通过Cloudflare CDN分发的图片。GCS为主要处理存储。               |
| D1 数据库        | `cf-d1-main-db-prod` (可选)             | (可选) 存储需要从边缘快速访问的摘要元数据或DO关联数据。主要结构化数据在GCP Firestore。                      |
| Vectorize Index  | `cf-vectorize-image-embeddings-prod` (可选) | 存储图像向量嵌入，支持相似性搜索。如果核心AI/向量在GCP，此项可能被GCP Vertex AI Vector Search替代或作为补充。                               |
| KV 命名空间 (可选) | `cf-kv-config-cache-prod`             | 用于缓存少量配置数据或实现简单的快速查找。                                   |
| Secrets Store    | 各 Worker 绑定专属密钥                  | 存储访问GCP服务所需的API密钥（通过引用环境变量）、HMAC密钥等。                               |
| Logpush (配置)   | `cf-logpush-gcp-logging-prod`           | 配置 Cloudflare Logpush 将日志导出到 GCP (例如通过 Pub/Sub 中转到 Cloud Logging)。 |

---

## 🚀 Google Cloud Platform (GCP) 资源清单 (核心后端服务与详细状态管理)

| 类型                             | 名称示例 (概念性，含环境)                      | 说明                                                                                                |
| -------------------------------- | --------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| 项目 ID                          | `in-gcp-project-prod-a1b2`                        | GCP 主项目标识。                                                                                      |
| **Identity Platform (GCIP)** | (项目内启用配置)                                | 用户身份认证和管理，支持 OAuth (Google/GitHub 等) 和其他登录方式。                                       |
| **Pub/Sub** |                                               |                                                                                                     |
| &nbsp;&nbsp;主题 (Topics)         | `in-ps-new-task-requests-prod`                | 用于接收由CF API Gateway发布的初始任务消息。                                                                                    |
|                                  | `in-ps-download-requests-prod`                | 传递下载请求 (GCP内部)。                                                                                        |
|                                  | `in-ps-metadata-requests-prod`                | 传递元数据提取请求 (GCP内部)。                                                                                    |
|                                  | `in-ps-ai-requests-prod`                      | 传递AI处理请求 (GCP内部)。                                                                                      |
|                                  | `in-ps-task-finalization-prod` (可选)         | (可选) GCP流程全部完成后，发布消息触发一个最终回调CF DO的Function。                                     |
| &nbsp;&nbsp;订阅 (Subscriptions) | `in-ps-sub-download-trigger-prod`               | 下载服务的 Cloud Function/Run 订阅此，以获取下载任务。                                                   |
|                                  | (为每个处理阶段的主题创建对应订阅，含环境后缀)    | ...                                                                                                 |
| &nbsp;&nbsp;死信主题 (DLT)       | `in-ps-dlt-download-requests-prod`            | 存储下载请求处理失败的消息。                                                                                |
| **Cloud Functions / Cloud Run** | `gcp-func-download-image-prod`                 | Serverless 函数或容器服务，订阅 Pub/Sub 主题，执行核心业务逻辑（下载到GCS、元数据、AI）。将详细状态写入Firestore。                          |
|                                  | `gcp-func-metadata-processor-prod`             | ...                                                                                                 |
|                                  | `gcp-service-ai-processor-prod` (Cloud Run)        | ...                                                                                                 |
|                                  | `gcp-func-notify-cf-do-prod` (可选)           | (可选) 订阅最终任务完成/失败的Pub/Sub主题，负责回调Cloudflare DO更新最终状态。                                  |
| **Firestore (Native Mode)** | `in-fs-main-prod` (数据库ID)                    | NoSQL 文档数据库，用于存储**GCP内部各处理阶段的详细任务状态**、用户配置（原Firebase部分）、应用设置等。 |
| &nbsp;&nbsp;集合 (Collections)   | `user-preferences`, `task-process-details`    | Firestore 内的数据集合。`task-process-details`可以按`taskId`存储详细的中间步骤。                                                                              |
| **Cloud Storage (GCS)** | `in-gcs-images-prod-main`                     | **主要的对象存储**，用于GCP内部处理流程中图片的存储和读取。                                              |
| **Vertex AI Vector Search (可选)**| `in-vxai-idx-images-prod`                     | 如果需要更高级的向量搜索功能，可替代或补充 Cloudflare Vectorize。                                              |
| **Cloud Logging & Monitoring** | (项目内默认启用和配置)                          | 收集、分析和可视化来自所有GCP服务以及通过Cloudflare Logpush导入的日志和监控数据。                         |
| &nbsp;&nbsp;日志接收器 (Sinks)   | `in-logsink-cflogs-to-pubsub-prod`            | ...                                                                                                 |
| &nbsp;&nbsp;仪表盘与告警        | `in-dashboard-main-prod`, `in-alert-errors-prod`| 监控关键业务指标和系统健康度。                                                                            |
| **Service Accounts & IAM** | `sa-gcp-compute@in-project-prod-a1b2.iam.gserviceaccount.com` <br> `sa-cf-to-gcp-access@...` | GCP服务自身运行的服务账号。用于授权 Cloudflare Workers 访问GCP资源 (如Pub/Sub发布)的服务账号。IAM 策略定义权限。 |
| **Secret Manager & API 密钥** | (通过 Secret Manager 管理)                    | 用于 GCP 服务间或外部应用访问 GCP API 的密钥。Cloudflare Worker 中使用的 GCP 凭证也应引用此处管理的密钥。 |

---

## GITHUB"> GitHub 资源清单 (代码管理与 CI/CD)

| 类型            | 名称示例                               | 说明                                                                    |
| --------------- | -------------------------------------- | ----------------------------------------------------------------------- |
| Repository      | `your-username/in-project`             | GitHub 上的主代码仓库，采用 Monorepo 结构。                               |
| GitHub Actions  | `.github/workflows/deploy-prod.yml`    | CI/CD 工作流，定义自动化测试、构建、部署到 Vercel, Cloudflare, GCP的流程。 |
|                 | `.github/workflows/ci-dev.yml`         | 开发/预览环境CI/CD工作流。                                                 |
| Secrets         | `GCP_SA_KEY_TERRAFORM_PROD`, `CF_API_TOKEN_PROD`, `VERCEL_TOKEN_PROD` | 在 GitHub Actions 中使用的、区分环境的敏感凭证，用于自动化部署。      |

---

## 📚 管理方式

- Cloudflare 和 GCP 资源主要由 **Terraform** (位于 `infra/` 目录) 管理。使用 Terraform Workspaces 管理不同环境 (prod, stg, dev)。
- Vercel 项目通过 Vercel 控制台与 GitHub 仓库绑定，配置通过 Vercel UI 和环境变量管理。
- 所有敏感配置信息通过各平台的 Secrets Management 进行安全管理。

---

## 🔒 安全说明 (摘要)

- **认证**: 用户认证由 GCP Identity Platform 处理。服务间认证采用 GCP 服务账号。
- **授权**: Cloudflare 和 GCP 均使用各自的 IAM 系统。
- **密钥管理**: 严格使用各平台提供的 Secrets Management 服务及 GitHub Actions Secrets。
- **网络安全**: Cloudflare 提供边缘安全。GCP 通过 VPC 和防火墙规则控制。
- **日志审计**: 所有日志集中到 Google Cloud Logging。

详细安全实践请参见 `secure-practices-*.md`。