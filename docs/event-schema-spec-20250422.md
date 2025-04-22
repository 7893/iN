# 📄 event-schema-spec-20250422.md
📅 Updated: 2025-04-22

## 核心事件接口设计：INEvent<T>

```ts
interface INEvent<T> {
  type: string; // 事件类型，如 image.downloaded
  timestamp: number;
  taskId: string;
  traceId?: string;
  payload: T;
}
```

## 示例：image.downloaded

```json
{
  "type": "image.downloaded",
  "timestamp": 1713770000000,
  "taskId": "task-abc123",
  "traceId": "trace-xyz987",
  "payload": {
    "imageKey": "bucket/abc.jpg",
    "source": "unsplash",
    "size": 3822991
  }
}
```

## 使用建议

- 事件结构统一由共享库生成，发送方和接收方依赖同一类型定义
- 所有订阅端需实现幂等处理
