# 🛡️ iN 安全检查清单  
📄 文档名称：security-checklist-20250422.md  
🗓️ 更新时间：2025-04-22  

---

## ✅ 云平台级

- [x] Cloudflare Secrets Store 配置并生效  
- [x] 所有 Worker 均已绑定密钥，不暴露在源码中  
- [x] Durable Object 实现访问权限受限  
- [x] 所有对外接口添加身份校验（HMAC or Firebase Auth）  
- [x] 日志中不打印敏感数据（如 token、secret）  

---

## ✅ Firebase 安全

- [x] Firestore 安全规则：用户只能访问自己的配置  
- [x] ID Token 验证已集成到 `auth.ts`  
- [x] 不启用 Firebase Functions，确保系统边界清晰  
- [x] 未开启匿名登录 / 手机号登录等不安全通道  

---

## ✅ Vercel 安全

- [x] 环境变量仅通过 ENV 注入，不在前端明文保存  
- [x] 使用 `.env` 区分 PUBLIC_ 和私有变量  
- [x] 所有部署仅允许绑定 GitLab 项目（防止 fork 篡改）  

---

## ✅ 接口与输入安全

- [x] 所有 API 使用 Zod 或 Schema 校验输入参数  
- [x] 所有 Queue 消费实现幂等处理逻辑  
- [x] 所有任务状态变更使用 DO 封装函数处理  
- [x] 所有 Queue 有 DLQ 绑定或失败报警机制  

---

## ✅ 日志与可观测性

- [x] TraceId 已实现并全链路传递  
- [x] 所有 Worker 使用结构化日志（JSON 格式）  
- [x] 已接入 Axiom 日志系统（或计划接入）  
