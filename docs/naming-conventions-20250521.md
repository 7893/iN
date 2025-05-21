# 🏷️ 命名规范总表 (架构版本 2025年5月21日)
📄 文档名称：naming-conventions-20250521.md (原 naming-conventions-20250422.md)
🗓️ 更新时间：2025-05-21

---
本规范旨在为 iN 项目在 Vercel, Cloudflare, Google Cloud Platform (GCP), GitHub 及代码库中的各类资源、文件、变量等提供统一的命名约定，以提高可读性、可维护性和自动化处理的便利性。

## 共通原则

- **风格**: 优先使用小写字母，单词间用连字符 `-` (kebab-case) 连接，尤其适用于云资源名称、文件名、URL路径等。代码内部变量和函数名遵循特定语言的约定 (如 TypeScript 中的 camelCase 或 PascalCase)。
- **前缀**: 使用项目标识 `in-` 作为大部分云资源和项目内部模块的前缀，便于识别和分组。
- **环境标识**: 对于区分环境的资源 (如 Staging, Production)，可以在名称中加入环境后缀，例如 `-stg`, `-prod`，或通过 Terraform workspace/分支策略管理。
- **日期戳**: 在某些一次性创建且不常变动的资源或版本化配置上，可以使用日期戳 (如 `YYYYMMDD`) 作为后缀。
- **简洁明了**: 名称应能清晰反映资源的用途或内容。避免过度缩写。

---

## GITHUB"> GitHub 命名规范

| 类型         | 示例                               | 描述与约定                                                              |
| ------------ | ---------------------------------- | ----------------------------------------------------------------------- |
| Repository   | `in-project` (或更具体的名称)      | 主代码仓库，Monorepo 结构。                                               |
| Branches     | `main`, `dev`, `feature/login-page`, `hotfix/critical-bug`, `release/v0.1.0` | 遵循 `branch-strategy-*.md` 中定义的策略。特征分支使用 `/` 分隔符。 |
| Actions Workflows | `ci-main.yml`, `deploy-prod.yml` | GitHub Actions 工作流文件名，描述其主要功能和触发条件。                       |
| Secrets      | `CF_API_TOKEN`, `GCP_SA_KEY_JSON`, `VERCEL_TOKEN` | Actions Secrets 名称，大写+下划线，清晰表明用途。                            |

---

## 📦 代码库 (Monorepo `packages/` 和 `apps/`) 命名规范

| 类型             | 示例                                    | 描述与约定                                                                |
| ---------------- | --------------------------------------- | ------------------------------------------------------------------------- |
| Packages (共享库) | `shared-libs`, `logger`, `eslint-config-custom` | `packages/` 目录下，kebab-case，描述库的功能。                               |
| Applications     | `vercel-frontend`, `cf-api-gateway`, `cf-task-coordinator-do`, `gcp-download-function` | `apps/` 目录下，`平台前缀-功能描述` 结构，kebab-case。                           |
| 文件与目录       | `user-service.ts`, `image-utils/`       | 小写，kebab-case。TypeScript 文件使用 `.ts` 或 `.tsx`。                       |
| 类名             | `TaskCoordinator`, `ImageProcessor`     | PascalCase。                                                              |
| 接口/类型名      | `ITaskState`, `UserProfile`, `TImageDimensions` | PascalCase，接口可使用 `I` 前缀，类型可使用 `T` 前缀（团队约定）。                  |
| 函数/方法名      | `getUserProfile`, `calculateImageSize`  | camelCase。                                                               |
| 变量/常量名      | `maxRetryCount` (camelCase), `MAX_RETRY_COUNT` (UPPER_SNAKE_CASE for constants) | 根据语言和作用域约定。                                                      |

---

## 🎨 Vercel 命名规范

| 类型         | 示例                   | 说明                                                        |
| ------------ | ---------------------- | ----------------------------------------------------------- |
| 项目名称     | `in-frontend-prod`     | Vercel 控制台中的项目名，可包含环境标识。                         |
| 环境变量前缀 | `NEXT_PUBLIC_` (Next.js), `VITE_` (Vite/SvelteKit) | 前端可访问的环境变量需遵循框架约定，确保不泄露敏感信息。 |
| 生产域名     | `in-project.vercel.app` (默认) 或自定义域名 |                                                             |

---

## ☁️ Cloudflare 命名规范

格式：`in-<类型>-<主要功能描述>[-环境][-可选标识]`，例如 `in-worker-api-gateway-prod`。
原日期戳 (`YYYYMMDD`) 可用于一次性创建且不通过 IaC 频繁更新的资源，对于 IaC 管理的资源，版本和环境通过代码和部署流程控制。

| 类型             | 示例                                    | 描述                                                                 |
| ---------------- | --------------------------------------- | -------------------------------------------------------------------- |
| Worker Script    | `in-worker-api-gateway`                 | Worker 服务名称 (在 `wrangler.toml` 和 Cloudflare Dashboard 中)。      |
| Durable Object   | `in-do-task-coordinator`                | Durable Object 类名绑定名称 (在 `wrangler.toml` 中)。                |
| R2 Bucket        | `in-r2-images`                          | R2 存储桶名称，需全局唯一。                                                 |
| D1 Database      | `in-d1-main-db`                         | D1 数据库名称。                                                        |
| Vectorize Index  | `in-vectorize-image-embeddings`         | Vectorize 索引名称。                                                   |
| KV Namespace     | `in-kv-config-cache`                    | KV 命名空间名称。                                                      |
| Logpush Job      | `in-logpush-gcp-logging`                | Logpush 作业名称。                                                     |
| Secrets (Worker) | `GCP_SERVICE_ACCOUNT_JSON_FOR_PUBSUB`   | Worker Secrets 名称 (在 `wrangler.toml` 或 Dashboard 中设置)。          |

---

## 🚀 Google Cloud Platform (GCP) 命名规范

格式：`in-<服务类型>-<主要功能描述>[-环境][-可选标识]`，遵循GCP资源命名限制 (通常小写字母、数字、连字符)。

| 类型                     | 示例                                           | 描述                                                              |
| ------------------------ | ---------------------------------------------- | ----------------------------------------------------------------- |
| Project ID               | `in-project-unique-id`                         | GCP 项目ID，全局唯一，创建后通常不可更改。                                |
| Pub/Sub Topic            | `in-pubsub-new-task-requests`                  | Pub/Sub 主题名称。                                                  |
| Pub/Sub Subscription     | `in-pubsub-sub-download-function`              | Pub/Sub 订阅名称。                                                |
| Cloud Function / Run     | `in-function-download-image`, `in-service-ai-processor` | Cloud Function 或 Cloud Run 服务名称。                              |
| Firestore Database       | `in-firestore-main`(default) 或指定数据库ID      | Firestore 数据库实例ID。                                            |
| Firestore Collection     | `user-preferences`, `task-states`              | Firestore 集合名称，通常 kebab-case 或 camelCase (取决于团队约定)。        |
| Cloud Storage (GCS) Bucket | `in-gcs-images-prod`, `in-gcs-log-archives`    | GCS 存储桶名称，需全局唯一。                                          |
| Service Account          | `sa-cf-worker-gcp-access@in-project-id.iam.gserviceaccount.com` | 服务账号邮箱地址，`sa-<描述>` 前缀。                               |
| IAM Role (Custom)        | `roles/inProject.pubsubPublisher`              | 自定义 IAM 角色名称。                                               |
| Secret Manager Secret    | `in-secret-cf-worker-gcp-sa-key`               | Secret Manager 中的密钥名称。                                       |
| Logging Sink             | `in-logging-sink-cf-logs-to-gcs`               | 日志接收器名称。                                                    |
| Monitoring Dashboard     | `in-dashboard-main-overview`                   | 自定义监控仪表盘名称。                                              |
| Vertex AI Vector Index   | `in-vertex-idx-image-embeddings`               | (如果使用) Vertex AI Vector Search 索引名称。                         |

---

## 📝 Terraform 资源命名

Terraform 内部的资源名称 (resource "type" "name") 应采用 `snake_case`，并能清晰反映其管理的云资源。
例如：
```terraform
resource "cloudflare_worker_script" "api_gateway" {
  name = "in-worker-api-gateway" # 云平台上的实际名称
  # ...
}

resource "google_pubsub_topic" "new_task_requests" {
  project = var.gcp_project_id
  name    = "in-pubsub-new-task-requests" # 云平台上的实际名称
  # ...
}