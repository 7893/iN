# 🔐 安全实践指南  
📄 文档名称：secure-practices-20250422.md  
🗓️ 更新时间：2025-04-22  

---

## ☁️ Cloudflare 安全策略

- 使用 `Secrets Store` 管理所有密钥，严禁硬编码
- 所有对外接口使用 `HMAC` 验签或 JWT 身份校验
- 每个 Worker 启用日志输出 traceId 以便溯源
- Durable Object 实现状态只允许特定 Worker 写入
- 所有 Queue 消费逻辑实现幂等处理（防止重放攻击）

---

## 🔐 Firebase 安全实践

- 使用 Firebase Auth 提供用户身份认证（支持 OAuth）
- 所有用户配置存储于 Firestore，规则限定为“仅允许本人读写”
- 在 `auth.ts` 中封装对 Firebase ID token 的解析与验证逻辑
- 禁用 Firebase Cloud Functions，避免平台分裂

---

## 🧬 Vercel 安全实践

- 通过 Vercel ENV 注入前端配置，避免前端硬编码
- 区分 `VERCEL_ENV`：dev, preview, production，对应不同后端 API
- 所有与 API 的通信需携带身份凭证（JWT/HMAC）
- 在前端构建阶段通过 `.env` 控制公开变量范围

---

## 📋 Secrets 与变量管理

- `.env.secrets` 为单一来源，手动维护
- 使用 `tools/sync-to-gitlab.sh` / `sync-runtime-to-cloudflare.sh` 同步变量
- Vercel ENV 可通过控制台或 CLI 设置（推荐以 `PUBLIC_` 前缀区分前端用）

---

## 🔁 其他建议

- 引入 Axiom 日志监控，设置异常告警阈值
- 使用 DLQ（Dead Letter Queue）捕获失败任务，避免任务死循环
- 所有传入参数建议使用 Zod 校验类型与范围
