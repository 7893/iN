# 🛠 local-dev-strategy-20250422.md
_本地开发流程与模拟环境建议_

## ✅ 工具推荐
- Wrangler v4 CLI
- Vitest + tsx 本地测试执行
- Miniflare（可选）：模拟 DO / KV / D1

## ⚙️ 本地开发流程

### 1. 单 Worker 本地测试
```bash
cd apps/in-worker-D-download-20250402
wrangler dev
```
支持访问 `localhost:8787` 进行 API 测试。

### 2. 模拟 Queue 推送
使用 CURL/脚本直接 POST 消息至 dev 中监听的 `queue()`。建议写 test helper：
```ts
POST http://localhost:8787
Body: { "taskId": "...", "imageUrl": "..." }
```

### 3. Durable Object 测试
可通过绑定 Stub 模拟交互：
```ts
const id = env.TASK_COORDINATOR_DO.idFromName(taskId)
const stub = env.TASK_COORDINATOR_DO.get(id)
await stub.fetch("/status")
```

## 🧪 自动化测试建议
- 单元测试使用 Vitest + Mocks
- 集成测试推荐通过 wrangler dev 模拟队列流转

## 📝 注意事项
- 多 Worker 协同推荐 mock handler 流转测试
- 所有请求建议传递 traceId 便于后期追踪

---
文件名：local-dev-strategy-20250422.md  
生成时间：20250422
