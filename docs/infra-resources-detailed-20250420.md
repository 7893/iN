# 📦 iN 项目基础设施资源详解（20250420）

> 本文档详细记录 iN 项目使用的全部基础设施资源，覆盖 Cloudflare、Firebase、Vercel 三个平台。

---

## ☁️ Cloudflare 资源清单（主控系统）

| 类型 | 名称示例 | 说明 |
|------|-----------|------|
| Workers | `in-worker-a-api-gateway-20250402` 等 11 个 | 所有 API、任务处理逻辑运行在 Worker 中，按模块独立部署 |
| Durable Object | `in-do-a-task-coordinator-20250402` | 任务状态协调器，管理任务状态生命周期 |
| Queues | `in-queue-a-image-download-20250402` 等 7 个 | 异步任务主链与副作用事件链 |
| R2 Bucket | `in-r2-a-image-bucket-20250402` | 图像原图与中间结果文件存储 |
| D1 数据库 | `in-d1-a-database-20250402` | 结构化元数据、任务记录、用户配置 |
| KV 命名空间 | `in-kv-a-runtime-config-20250402` | 配置缓存 / 快速索引表等小型数据存储 |
| Vectorize Index | `in-vectorize-a-index-20250402` | 图像向量嵌入与相似图查询支持 |
| Secrets Store | 各 Worker 绑定专属密钥 | 包含 `RUNTIME_HMAC_SECRET`、AI 密钥等运行时密钥 |
| Logpush | `in-logpush-a-axiom-20250402` | 推送结构化日志至 Axiom 用于观测与告警 |

---

## 🔐 Firebase 资源清单（辅助用户身份与配置）

| 类型 | 名称 | 说明 |
|------|------|------|
| 项目 ID | `in-fb-core-20250420` | Firebase 主项目标识，与 Vercel / API 绑定配合 |
| Auth | Gmail / GitHub 登录启用 | 用于用户 OAuth 登录与 token 获取 |
| Firestore | `presets` / `favorites` 集合 | 用户配置存储（偏好、收藏夹、下载预设等） |
| API 密钥 | 环境变量中管理 | Firebase SDK 使用的密钥，仅在后端使用 |
| Firebase 控制台 | https://console.firebase.google.com/project/in-fb-core-20250420 | 控制台管理认证与规则设置等 |

---

## 🎨 Vercel 资源清单（前端展示平台）

| 类型 | 名称 | 说明 |
|------|------|------|
| 项目名称 | `in-vc-pages-20250420` | 前端托管项目，SvelteKit 渲染用户界面 |
| Team | 默认或个人 Team | 用于集成 GitLab 仓库并部署 Preview |
| 环境变量 | 与 GitLab 同步管理 | 包含 `API_GATEWAY_URL`, `FIREBASE_CONFIG`, `PUBLIC_SITE_ID` 等 |
| 部署分支 | `main`, `preview/*` | Vercel 自动部署分支（与 GitHub Actions 或 GitLab 配合） |
| SSR 支持 | 启用 Vercel Edge Functions（可选） | 当前采用 SSG / ISR + API 接口结合 |
| Preview 链接 | `*.vercel.app` | 各分支生成的预览地址，用于测试与迭代展示 |

---

## 📚 管理方式

- 所有 Cloudflare 资源由 Terraform 管理（位于 `infra/`）
- Firebase 项目手动初始化，配置信息记录在 `.env.secrets`
- Vercel 项目通过控制台与 GitLab 仓库绑定，配置由 `project-settings` 与 `wrangler.toml` 协同维护

---

## 🔒 安全说明

- 所有密钥均存放于 `.env.secrets` 并通过以下脚本同步：
  - `tools/sync-runtime-to-cloudflare.sh`
  - `tools/sync-to-gitlab.sh`
- Firebase API Key 仅供后端调用，前端使用的公开配置通过 ENV 注入控制暴露
- 日志与认证信息使用 `traceId`, `taskId`, `userId` 严格结构化记录

---

