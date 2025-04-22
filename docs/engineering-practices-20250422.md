# 🧠 iN 工程实践说明  
📄 文档名称：engineering-practices-20250422.md  
🗓️ 更新时间：2025-04-22  

---

## ✅ 工程结构设计

- 使用 Monorepo 管理：前端、后端 Worker、共享库、IaC、工具脚本集中管理
- 使用 pnpm + turborepo 实现依赖追踪与缓存优化
- 所有应用（apps/）与库（packages/）严格职责分离
- 基于 wrangler.toml 与 terraform 实现完整资源与服务配置统一

---

## 🧪 开发与测试流程

- 单元测试：Vitest 用于所有函数逻辑测试
- 集成测试：wrangler dev + curl/Postman 本地调试接口与 DO 行为
- CI 流程：通过 GitLab 执行 lint → test → build → terraform plan → deploy

---

## 🛡️ 安全与认证实践

- 接口级：所有请求必须通过 JWT/HMAC 验证
- 用户级：使用 Firebase Auth 实现 OAuth 登录（Google/GitHub）
- 配置级：所有密钥集中存储，禁止硬编码，使用 Secrets Store 管理
- Worker 层级隔离：下载、元数据、AI、API 均拆分 Worker，权限最小化

---

## 🔁 架构演进与插件机制

- 主链稳定后可引入事件队列（Pub/Sub）拓展通知与索引等旁路逻辑
- Vectorize 与 Logpush 接入支持图像搜索与日志分析
- 后续引入 Feature Flags、Canary 发布机制优化部署体验
