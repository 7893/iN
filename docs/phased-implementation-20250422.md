# 🧱 iN 分阶段实施计划  
📄 文档名称：phased-implementation-20250422.md  
🗓️ 更新时间：2025-04-22  

---

## 🎯 项目目标

以 Cloudflare 为核心平台，结合 Firebase 与 Vercel，构建一套异步、事件驱动、可观测、模块化的智能图像处理系统。  
本计划旨在引导从初始化到核心逻辑开发再到前后端集成与上线的完整实施路径。

---

## 📊 阶段概览

| 阶段 | 目标 | 涉及平台 |
|------|------|-----------|
| 阶段 0️⃣ | 项目结构初始化 + 工具链搭建 | 本地, GitLab |
| 阶段 1️⃣ | 构建核心资源 + 共享库 | Cloudflare |
| 阶段 2️⃣ | 实现任务主链逻辑 | Cloudflare |
| 阶段 3️⃣ | 构建 API 接口与认证集成 | Cloudflare + Firebase |
| 阶段 4️⃣ | 开发 SPA 前端 + 与后端集成 | Vercel + Firebase |
| 阶段 5️⃣ | 可观测性、日志告警、安全加固 | 全平台 |

---

## ✅ 阶段 0：项目初始化（1-2 天）

- 初始化 GitLab 仓库，配置 `.gitignore`, `.editorconfig`
- 配置 `pnpm + turborepo` 管理 Monorepo
- 创建目录结构：`apps/`, `packages/`, `infra/`, `tools/`, `docs/`
- 初始化 wrangler 和 terraform 项目
- 设置 Vercel 项目并连接 GitLab 仓库
- 启动 Firebase 项目（只启用 Auth 与 Firestore）

---

## ✅ 阶段 1：核心资源创建与共享库搭建（2-3 天）

- 使用 Terraform 创建：
  - R2 Bucket
  - D1 数据库（含初始 schema）
  - 任务主链队列（及 DLQ）
  - Durable Object 命名空间
  - Vectorize Index
  - Logpush 配置推送至 Axiom
- 初始化共享库（packages/shared-libs）：
  - `logger.ts`, `trace.ts`, `task.ts`, `auth.ts`
- 同步 Secrets 至 Cloudflare 与 GitLab

---

## ✅ 阶段 2：任务主链逻辑实现（5-7 天）

- 实现 Durable Object 状态机逻辑（taskId 状态流转）
- 编写队列消费者 Worker：
  - 下载（从远端拉取 → 写入 R2 → 推入元数据队列）
  - 元数据（读取 R2 → 提取元信息 → 写入 D1）
  - AI（分析并写入 Vectorize）
- 确保幂等、日志、traceID 等结构化实现
- 编写 Vitest 单测

---

## ✅ 阶段 3：API 层构建 + 身份认证接入（3-5 天）

- 构建 API Gateway Worker，实现统一入口、路由与认证
- 实现 Config API、Query API 等模块化 Worker
- 集成 Firebase Auth（通过 ID token 验证用户身份）
- 实现基础 HMAC 签名机制，支持服务间验证

---

## ✅ 阶段 4：前端 SPA 开发 + 集成（5-7 天）

- 使用 SvelteKit 搭建 Vercel 前端项目
- 实现以下页面：
  - 登录页面（对接 Firebase）
  - 配置页面（读取/保存用户 preset）
  - 状态面板页面（查询任务状态）
  - 任务详情页面（展示图片与 AI 结果）
- 环境变量配置：使用 `.env` + `vercel` 环境管理 UI 配置

---

## ✅ 阶段 5：可观测性、告警与安全加固（持续集成）

- 配置 Cloudflare Logpush 至 Axiom
- 创建 Axiom 仪表盘：队列延迟、DO 错误、任务耗时
- 接入 Secrets 管理脚本
- 审查 Firebase Firestore / Auth 权限规则
- 加入输入验证（Zod）与 API 限流策略
- 设计 DLQ 处理机制（失败任务监控与重试）

---

## 🔁 后续与可选扩展阶段

- 多租户支持（按 tenantId 设计表结构与索引隔离）
- 向量搜索页面（对接 Vectorize 实现图像推荐）
- 插件机制（事件发布 + Worker 订阅扩展）
- 蓝绿部署与 Canary 自动化上线支持
- 合约测试与混沌工程（注入失败验证稳定性）

---

📘 本文档将随着阶段推进持续更新  
建议与 `project-overview`、`infra-resources-detailed` 一并维护
