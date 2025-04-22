# ☑️ dlq-handling-guide-20250422.md
_DLQ（Dead Letter Queue）自动处理机制设计指南_

## 🧩 背景

DLQ 是处理失败队列中无法重试的消息，保障主链稳定运行的重要组件。

## ✅ 建议机制

1. 所有 DLQ 均绑定日志增强 Worker 或记录系统
2. 持续轮询队列消息（可设置间隔触发）
3. 失败原因记录后分类：
   - 可重试：重新推入主队列（最多 3 次）
   - 不可重试：记录日志 + 告警 + 丢弃
   - 待人工分析：持久化到 KV/R2 中，供后续审计

## 🔁 示例脚本（伪代码）

```ts
while (true) {
  const msg = await dequeue(DLQ);
  if (shouldRetry(msg)) {
    enqueue(MainQueue, msg);
  } else {
    logToAxiom(msg);
  }
}
```

---
文件名：dlq-handling-guide-20250422.md
生成时间：20250422
