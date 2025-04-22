# 🧭 iN 项目最佳实践手册  
📄 文档名称：best-practices-20250422.md  
🗓️ 更新时间：2025-04-22

---

## 📦 架构分层最佳实践

- 使用 Cloudflare Workers 拆分任务与 API 层职责（apps/* 分层）
- Durable Object 用于状态强一致管理，禁止状态漂移
- 所有副作用逻辑抽出封装为共享库（packages/shared-libs/*）
- 所有任务流由 Queue 驱动，Worker 消费逻辑保持幂等性
- 所有 API 接口前置 Gateway Worker 做统一认证与路由

---

## 🔐 安全最佳实践

- 所有敏感配置通过 `.env.secrets` 管理，并同步至 GitLab/Cloudflare
- Firebase Auth 用于用户层面认证，HMAC 用于服务间签名验证
- 日志中禁止输出 token、key、cookie 等信息
- 所有接口需做签名验证或身份校验，接入前强制使用 `auth.ts`

---

## 🧩 前端开发最佳实践

- 使用 SvelteKit 构建 SPA，部署于 Vercel，配置支持 ENV 区分环境
- 所有 API 调用封装统一客户端并处理错误与 token 注入
- 尽量使用公共组件与 tailwind 统一 UI 样式
- 用户配置页面与状态列表页面分离，便于维护

---

## 🧪 测试与 CI 最佳实践

- 所有共享逻辑须编写 Vitest 单测，确保纯函数覆盖率
- Worker 需本地 wrangler dev + traceId 联调日志观察
- GitLab CI 检查 Lint、Test、Build、Terraform Plan
- 推送至主分支必须通过 GitLab 合并请求审查

---

## 📈 可观测性最佳实践

- 所有日志统一通过 `logger.ts` 输出，格式化为 JSON 并带 traceId
- Logpush 推送日志至 Axiom，结合仪表盘实现监控
- 所有 Worker 和 API 请求附加 traceId Header 以追踪链路
