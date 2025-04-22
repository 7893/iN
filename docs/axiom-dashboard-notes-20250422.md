# 📊 axiom-dashboard-notes-20250422.md
_日志与指标接入 Axiom 的实战指南_

## ✅ Logpush 设置

- 所有 Worker 需启用 `logpush = true`
- 日志字段要求结构化（JSON 格式）：
```json
{
  "timestamp": "...",
  "traceId": "...",
  "taskId": "...",
  "worker": "download",
  "message": "Downloaded image",
  "level": "info"
}
```

## 📈 推荐指标

- 队列处理时间（Queue Lag）
- 每个 Worker 的错误率
- DLQ 长度变化趋势
- API 请求耗时（可打入日志）
- 任务完成率

## 🧩 仪表盘结构建议

| 面板 | 内容 |
|------|------|
| 概览 | 任务总数、失败数、平均耗时 |
| 下载 | 下载错误率、图片大小分布 |
| AI | 分析耗时、常见标签 |
| DLQ | 死信队列趋势图 |
| traceId | 支持按 traceId 跟踪完整链路 |

---

文件名：axiom-dashboard-notes-20250422.md  
生成时间：20250422
