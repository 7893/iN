# 🧩 event-example-log-subscriber-20250422.md
_事件驱动架构示例订阅者：日志增强 Worker_

## 🎯 目标

作为事件驱动架构 MVP 的第一订阅者，`log-enhancer-worker` 用于消费任务链事件并生成更丰富的日志记录。

## 🧱 架构角色

- 订阅队列：ImageEventsQueue
- 消费事件：如 `image.downloaded`, `metadata.extracted`, `ai.analyzed`
- 输出增强日志：包含阶段状态、处理时间、traceId、taskId 等

## 🧪 示例事件格式（from shared-libs/events/）

```ts
type INEvent<T extends string, P = unknown> = {
  type: T;
  timestamp: number;
  traceId: string;
  taskId: string;
  payload: P;
};
```

## 🚀 示例逻辑（伪代码）

```ts
onQueueMessage(event) {
  logToAxiom({
    traceId: event.traceId,
    taskId: event.taskId,
    stage: event.type,
    ...event.payload
  });
}
```

---

文件名：event-example-log-subscriber-20250422.md  
生成时间：20250422
