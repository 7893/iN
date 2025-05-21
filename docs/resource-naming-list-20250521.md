# 🔖 iN 项目资源命名清单 (架构版本 2025年5月21日)
📄 文档名称：resource-naming-list-20250521.md (原 resource-naming-list-20250422.md)
🗓️ 更新时间：2025-05-21

---
本清单是 `naming-conventions-*.md` 的具体示例和快速查阅版本，列出了 iN 项目在 Vercel, Cloudflare, Google Cloud Platform (GCP) 和 GitHub 中主要资源的命名示例。所有命名应遵循已定义的命名规范。

## GITHUB"> GitHub

| 类型       | 示例                     |
| ---------- | ------------------------ |
| Repository | `in-project`             |
| Workflow   | `ci-main.yml`, `deploy-prod.yml` |

---

## 🎨 Vercel

| 类型       | 示例                         |
| ---------- | ---------------------------- |
| 项目名称   | `in-frontend-prod`           |
| 环境变量 | `NEXT_PUBLIC_API_BASE_URL` |

---

## ☁️ Cloudflare

基本格式：`in-<类型>-<功能名>[-环境]`

| 类型            | 示例                                  |
| --------------- | ------------------------------------- |
| Worker Script   | `in-worker-api-gateway`               |
|                 | `in-worker-frontend-server` (如果采用) |
| Durable Object  | `in-do-task-coordinator`              |
| R2 Bucket       | `in-r2-images`                        |
| D1 Database     | `in-d1-main-db`                       |
| Vectorize Index | `in-vectorize-image-embeddings`       |
| KV Namespace    | `in-kv-app-config`                    |
| Logpush Job     | `in-logpush-to-gcp`                   |

---

## 🚀 Google Cloud Platform (GCP)

基本格式：`in-<服务简称>-<功能名>[-环境]` (需符合GCP各服务的具体命名约束)

| 类型                     | 示例                                        |
| ------------------------ | ------------------------------------------- |
| Project ID               | `in-project-prod-12345` (需全局唯一)        |
| Pub/Sub Topic            | `in-ps-new-task-requests`                   |
|                          | `in-ps-dlt-new-task-requests` (死信主题)    |
| Pub/Sub Subscription     | `in-ps-sub-download-function`               |
| Cloud Function / Run     | `in-func-download-image`                    |
|                          | `in-svc-ai-processor` (Cloud Run 服务)      |
| Firestore Database       | `in-fs-main`(default)                       |
| Firestore Collection     | `user-preferences`, `task-states-detail`    |
| Cloud Storage (GCS) Bucket | `in-gcs-images-prod-data`                   |
| Service Account          | `sa-in-compute-access@in-project-prod-12345.iam.gserviceaccount.com` |
| Secret Manager Secret    | `in-secret-cf-sa-key`                       |
| Logging Sink             | `in-logsink-cf-to-pubsub`                   |
| Monitoring Dashboard     | `in-dashboard-overview`                     |
| Vertex AI Vector Index   | `in-vxai-idx-images` (如果使用)             |

---

## 📝 Terraform 内部资源名

采用 `snake_case`，清晰描述资源。

| 类型                         | Terraform 资源名示例                |
| ---------------------------- | ----------------------------------- |
| Cloudflare Worker Script     | `api_gateway_worker`                |
| Cloudflare R2 Bucket         | `images_bucket`                     |
| GCP Pub/Sub Topic            | `new_task_requests_topic`           |
| GCP Cloud Function           | `download_image_function`           |
| GCP Firestore Database       | `main_firestore_db`                 |

---

✅ **总结**
所有资源命名需与 `naming-conventions-*.md` 中的规范保持一致，确保在多云环境中资源的可识别性、可管理性和自动化处理的便利性。