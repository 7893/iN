# 📦 iN 项目基础设施资源详解 (架构版本 2025年5月21日)

> 本文档详细记录 iN 项目使用的基础设施资源，覆盖 Vercel、Cloudflare 和 Google Cloud Platform (GCP) 三个平台，并提及 GitHub 作为代码管理和 CI/CD 工具。所有资源尽量利用永久免费额度。

---

## 🎨 Vercel 资源清单 (前端展示平台)

| 类型       | 名称示例 (概念性)          | 说明                                                                 |
| ---------- | -------------------------- | -------------------------------------------------------------------- |
| 项目名称   | `in-frontend`              | Vercel 上的前端项目，例如使用 SvelteKit/Next.js 构建的用户界面。         |
| 部署分支   | `main`, `dev`, `feature/*` | 自动从 GitHub 仓库的相应分支部署到 Vercel 的 Production, Preview 环境。 |
| 环境变量   | `NEXT_PUBLIC_API_GATEWAY_URL`, `NEXT_PUBLIC_GCIP_CONFIG_PARAMS` 等 | 用于前端应用连接后端API和认证服务。通过 Vercel 项目设置管理。             |
| Hobby Plan | N/A                        | 利用 Vercel 的免费 Hobby Plan 提供的构建、部署、CDN 和带宽。            |

---

## ☁️ Cloudflare 资源清单 (边缘网络、API网关、状态协调与边缘存储)

| 类型             | 名称示例 (根据 `naming-conventions-*.md`) | 说明                                                                  |
| ---------------- | --------------------------------------- | --------------------------------------------------------------------- |
| Workers          | `in-worker-a-api-gateway-20250521`      | API 网关，处理所有入站API请求，路由，认证预处理。                         |
|                  | (其他轻量级边缘逻辑Worker)                  | 例如，自定义Header处理，简单的请求转换等。                               |
| Durable Object   | `in-do-a-task-coordinator-20250521`   | 任务状态协调器，管理每个任务的生命周期状态。                               |
| R2 Bucket        | `in-r2-a-image-bucket-20250521`       | 存储图像原图、处理结果。               |
| D1 数据库        | `in-d1-a-database-20250521`           | 存储结构化元数据、任务记录的摘要等，适合边缘访问。                      |
| Vectorize Index  | `in-vectorize-a-index-20250521`       | 存储图像向量嵌入，支持相似性搜索。                               |
| KV 命名空间 (可选) | `in-kv-a-config-cache-20250521`       | 用于缓存少量配置数据或实现简单的快速查找。                                   |
| Secrets Store    | 各 Worker 绑定专属密钥                  | 存储访问GCP服务所需的API密钥（通过引用环境变量）、HMAC密钥等。                               |
| Logpush (配置)   | `in-logpush-a-gcp-logging-20250521`   | 配置 Cloudflare Logpush 将日志导出到 GCP (例如通过 Pub/Sub 中转到 Cloud Logging)。 |

---

## 🚀 Google Cloud Platform (GCP) 资源清单 (核心后端服务)

| 类型                             | 名称示例 (概念性)                             | 说明                                                                                                |
| -------------------------------- | --------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| 项目 ID                          | `in-gcp-project-20250521`                     | GCP 主项目标识。                                                                                      |
| **Identity Platform (GCIP)** | (项目内启用配置)                                | 用户身份认证和管理，支持 OAuth (Google/GitHub 等) 和其他登录方式。                                       |
| **Pub/Sub** |                                               |                                                                                                     |
| &nbsp;&nbsp;主题 (Topics)         | `in-pubsub-topic-new-task`                    | 用于接收新任务消息。                                                                                    |
|                                  | `in-pubsub-topic-download-requests`           | 传递下载请求。                                                                                        |
|                                  | `in-pubsub-topic-metadata-requests`           | 传递元数据提取请求。                                                                                    |
|                                  | `in-pubsub-topic-ai-requests`                 | 传递AI处理请求。                                                                                      |
| &nbsp;&nbsp;订阅 (Subscriptions) | `in-pubsub-sub-download-trigger`               | 下载服务的 Cloud Function/Run 订阅此，以获取下载任务。                                                   |
|                                  | (为每个处理阶段的主题创建对应订阅)                | ...                                                                                                 |
| &nbsp;&nbsp;死信主题 (DLT)       | `in-pubsub-dlt-download-requests`             | 存储下载请求处理失败的消息。                                                                                |
| **Cloud Functions / Cloud Run** | `in-service-download-processor`              | Serverless 函数或容器服务，订阅 Pub/Sub 主题，执行核心业务逻辑（下载、元数据、AI）。                          |
|                                  | `in-service-metadata-processor`              | ...                                                                                                 |
|                                  | `in-service-ai-processor`                    | ...                                                                                                 |
| **Firestore (Native Mode)** | `in-firestore-db` (数据库实例)                  | NoSQL 文档数据库，用于存储用户配置、应用设置、部分任务元数据和状态的持久化（作为D1的补充或替代）。 |
| &nbsp;&nbsp;集合 (Collections)   | `user-preferences`, `task-details-gcp`        | Firestore 内的数据集合。                                                                              |
| **Cloud Storage (GCS) (可选)** | `in-gcs-bucket-images-main`                 | 对象存储，可作为 R2 的补充/替代，或当计算在GCP时作为主要存储。                                              |
| **Vertex AI Vector Search (可选)**| `in-vertex-ai-vector-index`                   | 如果需要更高级的向量搜索功能，可替代 Cloudflare Vectorize。                                              |
| **Cloud Logging & Monitoring** | (项目内默认启用和配置)                          | 收集、分析和可视化来自所有GCP服务以及通过Cloudflare Logpush导入的日志和监控数据。                         |
| &nbsp;&nbsp;日志接收器 (Sinks)   | (配置Logpush的目标，如特定Pub/Sub或GCS桶)       | ...                                                                                                 |
| &nbsp;&nbsp;仪表盘与告警        | (自定义创建)                                  | 监控关键业务指标和系统健康度。                                                                            |
| **Service Accounts & IAM** | `sa-cf-worker-gcp-access@...`                     | 服务账号，用于授权 Cloudflare Workers (或其他服务) 访问GCP资源 (如Pub/Sub, Firestore)。IAM 策略定义权限。 |
| **API 密钥 & Secret Manager** | (通过 Secret Manager 管理)                    | 用于 GCP 服务间或外部应用访问 GCP API 的密钥。Cloudflare Worker 中使用的 GCP 凭证也应在此管理并通过安全方式注入。 |

---

## GITHUB"> GitHub 资源清单 (代码管理与 CI/CD)

| 类型            | 名称示例                               | 说明                                                                    |
| --------------- | -------------------------------------- | ----------------------------------------------------------------------- |
| Repository      | `your-username/in-project`             | GitHub 上的主代码仓库，采用 Monorepo 结构。                               |
| GitHub Actions  | `.github/workflows/deploy-dev.yml`     | CI/CD 工作流，定义自动化测试、构建、部署到 Vercel, Cloudflare, GCP的流程。 |
|                 | `.github/workflows/deploy-prod.yml`    | 生产环境部署工作流。                                                      |
| Secrets         | `GCP_SERVICE_ACCOUNT_KEY`, `CF_API_TOKEN`, `VERCEL_TOKEN` | 在 GitHub Actions 中使用的敏感凭证，用于自动化部署。                      |

---

## 📚 管理方式

- Cloudflare 和 GCP 资源主要由 **Terraform** (位于 `infra/` 目录) 管理。
- Vercel 项目通过 Vercel 控制台与 GitHub 仓库绑定，配置通过 Vercel UI 和环境变量管理。
- 所有敏感配置信息（API密钥、服务账号密钥等）通过各平台的 Secrets Management (Cloudflare Secrets, GCP Secret Manager, Vercel Environment Variables, GitHub Actions Secrets) 进行安全管理，禁止硬编码到代码或 Terraform 配置中。脚本 (`tools/`) 可能用于辅助同步非敏感配置或执行特定任务。

---

## 🔒 安全说明 (基于新架构调整)

- **认证**: 用户认证由 GCP Identity Platform 处理。服务间认证根据需要采用 OAuth 2.0 (例如，GCP 服务账号) 或其他机制（如 Cloudflare Worker 间的 HMAC 签名，如果适用）。
- **授权**: Cloudflare 和 GCP 均使用各自的 IAM 系统进行精细的权限控制。Vercel 项目访问控制。
- **密钥管理**: 严格使用各平台提供的 Secrets Management 服务，并通过 GitHub Actions Secrets 安全地注入到 CI/CD 流程中。
- **网络安全**: Cloudflare 提供外围网络安全。GCP 服务间的网络通信可以通过 VPC 和防火墙规则进行控制。
- **日志审计**: 所有操作和访问日志集中到 Google Cloud Logging 进行审计和监控。