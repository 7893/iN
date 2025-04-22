# 📦 共享库结构与职责概览  
📄 文档名称：shared-libs-overview-20250422.md  
🗓️ 更新时间：2025-04-22  

---

## 🧩 共享库结构（packages/shared-libs）

项目中共享库用于封装跨 Worker / API / 前端 的通用逻辑，确保副作用集中、可测试、可维护。

---

## 📁 子模块一览

| 模块名 | 说明 |
|--------|------|
| `logger.ts` | 提供结构化 JSON 日志输出（含 traceId、taskId、level 等字段），所有 Worker 必须接入。 |
| `trace.ts` | 生成与传递 traceId，支持通过 Header/Queue 消息中提取和链路传播。 |
| `task.ts` | 操作 Task Coordinator DO 的统一封装（如更新状态、写入元信息、推进流程）。 |
| `auth.ts` | 支持 HMAC 与 Firebase ID Token 双重认证逻辑，供 API Gateway 与下游 Worker 调用。 |
| `constants.ts` | 系统常量、任务状态枚举、队列命名等。 |
| `events/` | 定义事件接口，如 `INEvent<T>`，支持未来事件订阅扩展。 |
| `types.ts` | 公共类型定义，包括消息体结构、任务定义、配置项模型等。 |

---

## 🧠 特别说明

- 所有逻辑鼓励函数式设计（无副作用、可组合）
- 日志与 traceId 强制集成，保障可观测性
- DO 与 Queue 的接口必须使用封装函数，统一处理幂等检查与异常日志
- `auth.ts` 中集成 Firebase Admin SDK 用于 ID token 验证
- 可选配置：开放每个模块的 mock 实现以便测试

---

# ✅ 总结

共享库是 iN 架构中的核心抽象层，确保所有 Worker/API/前端模块行为一致、结构清晰、可复用。
