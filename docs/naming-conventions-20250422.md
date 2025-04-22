# 🏷️ 命名规范总表  
📄 文档名称：naming-conventions-20250422.md  
🗓️ 更新时间：2025-04-22  

---

## ☁️ Cloudflare 命名规范

格式：`in-<类型>-<顺序字母>-<功能名>-<日期>`

| 类型 | 示例 | 描述 |
|------|------|------|
| Worker | `in-worker-a-api-gateway-20250402` | 独立部署 Worker |
| Queue | `in-queue-b-download-20250402` | 消息队列；DLQ 用下一个字母 |
| Durable Object | `in-do-a-task-coordinator-20250402` | 状态机协调器 |
| R2 Bucket | `in-r2-a-original-images-20250402` | 原图存储桶 |
| D1 Database | `in-d1-a-metadata-20250402` | 元数据存储 |
| Vectorize Index | `in-vectorize-a-index-20250402` | 图像向量索引 |
| Logpush | `in-logpush-a-axiom-20250402` | 日志转发配置 |

---

## 🔐 Firebase 命名建议

| 项目 | 示例 | 说明 |
|------|------|------|
| Firebase Project ID | `in-firebase-202504` | 建议与主项目同名或近似 |
| Firestore Collection | `user-configs`, `presets` | 全部小写、带复数 |
| Auth Provider | `google`, `github` | OAuth 标准类型名 |

---

## 🌐 Vercel 命名建议

| 项目 | 示例 | 说明 |
|------|------|------|
| Vercel 项目名 | `in-pages` | 对应 SPA 前端项目 |
| 环境变量前缀 | `PUBLIC_CONFIG_` | 所有前端可访问变量 |
| 域名 | `in-pages.vercel.app` | 可自定义绑定 |
