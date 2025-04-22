# 🔖 iN 项目资源命名规范清单  
📄 文档名称：resource-naming-list-20250422.md  
🗓️ 更新时间：2025-04-22  

---

## ☁️ Cloudflare 命名规范

格式：`in-<类型>-<顺序字母>-<功能名>-<日期>`

| 类型 | 示例 | 描述 |
|------|------|------|
| Worker | in-worker-a-api-gateway-20250402 | 所有 Worker 必须加顺序和功能名 |
| Queue | in-queue-b-image-download-20250402 | DLQ 使用邻接字母（如 c 为主，d 为 DLQ） |
| DO | in-do-a-task-coordinator-20250402 | Durable Object 命名空间 |
| R2 | in-r2-a-storage-bucket-20250402 | 原图存储桶 |
| D1 | in-d1-a-database-20250402 | 元数据数据库 |
| Vectorize | in-vectorize-a-index-20250402 | 向量索引结构 |
| Logpush | in-logpush-a-axiom-20250402 | 日志推送配置项 |

---

## 🔐 Firebase 命名规范

| 项目 | 示例 | 说明 |
|------|------|------|
| Firebase Project ID | in-fb-project-202504 | 建议与主项目一致，并带时间戳 |
| Firestore Collection | user-config | 存储用户配置项 preset |
| Auth Provider | google / github | OAuth 登录方式 |

---

## 🎨 Vercel 命名规范

| 项目 | 示例 | 说明 |
|------|------|------|
| Vercel Project Name | in-pages | 对应前端 SPA 项目 |
| 环境变量前缀 | PUBLIC_CONFIG_ | 前端使用的 ENV |
| 域名（默认） | in-pages.vercel.app | 可选自定义域名绑定 |

---

# ✅ 总结

所有资源命名需保持唯一性、规范性、可追踪性，并与 Terraform 一致对齐，确保日志与资源管理统一。
