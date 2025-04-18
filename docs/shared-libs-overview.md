# iN 项目共享库与抽象层说明  
> 更新时间：2025‑04‑18 13:55 KST

## 概览  

本文汇总了 **iN 项目** 中被抽象为共享库，或独立于单个 Worker 的核心模块。  
目标：提高模块化、可维护性，践行关注点分离与函数式编程等现代工程范式。

---

## ✅ 共享库（`packages/shared‑libs/`）

| # | 模块 | 作用 | 典型特性 | 被谁使用 |
|---|------|------|----------|----------|
| 1 | **`logger.ts`** | 统一结构化日志 | 注入 `traceId / taskId / workerName`；支持 `debug/info/warn/error`；默认 `console` 输出，便于 Logpush | 所有 Worker |
| 2 | **`trace.ts`** | Trace ID 管理 | 生成 UUID/nanoid；从 Header / Queue 消息提取；上下文安全传播 | 所有 API & 任务 Worker |
| 3 | **`auth.ts`** | 认证/鉴权 | JWT 校验、HMAC 签名、产出 `INUserContext` | 全部 API Worker（经 API Gateway） |
| 4 | **`task.ts`** | DO 任务状态封装 | `setState()/getState()`；可选状态机校验；内置 Trace 日志 | config / download / metadata / ai Worker |
| 5 | **`events/`** | 事件模型 | 定义 `INEvent<T>`、集中 `event-types.ts` | 未来 Pub/Sub、日志一致化 |
| 6 | **`shared-utils/`** (可选) | 通用工具 | 时间格式化、`generateTaskId()`、重试逻辑、环境变量加载等 | 多个 Worker / 脚本 |

---

## ✅ 非 Worker 运行时模块

| 主题 | 工具 / 文件 | 说明 |
|------|------------|------|
| Secrets 管理 | **Cloudflare Secrets Store** | 统一密钥分发；本地 `.env`、`terraform.tfvars`、CI/CD 变量三方同步 |
| 请求校验 | `request-schema.ts` (Zod / Valibot) | API 入参模式验证，防御性编程 |
| 测试工具 | `test-utils.ts` | Mock 生成、Queue 消息模拟，服务于 Vitest/Jest |

---

## 🧩 汇总表

| 类别 | 路径 / 名称 | 作用描述 |
|------|-------------|----------|
| Logging | `shared‑libs/logger.ts` | 结构化 JSON 日志 |
| Tracing | `shared‑libs/trace.ts` | Trace ID 生成与透传 |
| Auth | `shared‑libs/auth.ts` | JWT / HMAC 认证 |
| Task 状态 | `shared‑libs/task.ts` | Durable Object 状态包装 |
| Event | `shared‑libs/events/` | 事件类型与接口 |
| Utils | `shared‑libs/shared-utils/` | 时间、ID、重试等通用函数 |
| Test Mocks | `shared‑libs/test-utils.ts` | 单元/集成测试辅助 |
| Schema | `shared‑libs/request-schema.ts` | API 输入校验 |
| Secrets | **Cloudflare Secrets Store** | 全球密钥分发与持久化 |

---

## 📘 小结  

上述模块化设计带来：

* 🌟 **一致性**：日志、追踪、认证等横切关注点一处维护  
* 🧪 **可测试性**：副作用集中、易于 Mock  
* 🔧 **类型安全**：共享接口 & Schema，减少契约漂移  
* 🚀 **长期可维护**：新增 Worker 可即插即用共享库

这一结构为 iN 架构的演进与团队协作奠定了坚实基础。
