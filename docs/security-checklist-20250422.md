# ✅ security-checklist-20250422.md

## 🔐 基础安全措施清单

- [x] 所有密钥通过 `.env.secrets` 管理，使用 Secrets Store 同步到平台
- [x] 所有 API 均添加身份认证机制（Firebase Auth 或 JWT/HMAC）
- [x] 所有输入参数通过 Zod 进行输入验证
- [x] Git 历史已清理敏感信息，CI 集成 Gitleaks
- [x] 日志中不输出原始 secret 内容
- [x] 所有日志均附带 traceId，支持链路追踪
- [x] 日志结构化，使用 JSON 格式，推送至 Axiom
- [x] 队列消费严格幂等，避免重复副作用
- [x] Queue 消费失败进入 DLQ，主链不阻塞
- [x] Durable Object 状态更新不可越权

## 🆕 新增项

- [x] DLQ 记录不得包含原始用户敏感数据（如原图路径、用户 ID）
- [x] 所有 traceId 日志中应去除 secret 字段，仅保留任务与流程状态

---

文档名：security-checklist-20250422.md  
更新日期：2025-04-22
