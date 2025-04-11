## 混合事件驱动架构 (Hybrid Event-Driven Architecture)

🎯 **目的:** 解释本项目采用“任务队列 + 事件队列”混合模式的原因，定义事件的标准化结构、不同队列的用途以及事件的命名规范。

---

### 为什么采用任务 + 事件混合模式？

纯粹的事件驱动架构（所有交互通过事件解耦）提供了极高的灵活性和可扩展性，但可能导致端到端业务流程难以追踪、分布式调试复杂、最终一致性管理困难。而纯粹的任务队列驱动则缺乏广播能力，难以灵活地增加对流程中某些状态变更感兴趣的“副作用”处理逻辑（如通知、统计、索引等）。

本项目采用**混合模式**旨在结合两者的优点：

1. **核心流程清晰可控:**  
   对于图片处理这种具有明确先后顺序的核心业务流程（下载 → 元数据 → AI），我们继续使用 **任务队列 (Task Queues)** 来驱动，便于状态管理与调试。

2. **副作用灵活解耦:**  
   对于流程中产生的关键**里程碑事件**（如图片下载完成、任务完成等），使用 **事件队列 (Event Queues)** 广播通知，供通知、统计、插件等模块响应。

3. **复杂度控制:**  
   将复杂性限制在副作用处理层，核心主流程保持可控、有序、具备状态跟踪能力。

---

### 队列用途定义

#### ✅ 任务队列 (Task Queues)

- **作用:** 驱动主流程，传递任务指令。
- **特点:** 顺序性强、责任明确。
- **示例:**  
  - `ImageDownloadQueue`  
  - `MetadataProcessingQueue`  
  - `AIProcessingQueue`
- **消费者:**  
  - download-worker  
  - metadata-worker  
  - ai-worker
- **关联状态:** 更新 Task Coordinator DO 中的任务状态。

#### ✅ 事件队列 (Event Queues)

- **作用:** 发布系统内已发生的重要事件。
- **特点:** 广播型、可多订阅、无状态依赖。
- **示例:**  
  - `ImageEventsQueue`  
  - `TaskLifecycleEventsQueue`
- **消费者:**  
  - notification-worker  
  - analytics-worker  
  - tag-indexer-worker
- **状态关联:** 不更新主状态，仅处理副作用。

---

### 发布事件的时机 (建议示例)

| 发布者 Worker       | 触发事件                      | eventType                   |
|---------------------|-------------------------------|-----------------------------|
| download-worker     | 图片下载成功                  | `image.downloaded`          |
| metadata-worker     | 元数据提取成功                | `image.metadata_extracted`  |
| ai-worker           | AI 分析结果写入成功           | `image.analyzed`            |
| ai-worker / others  | 全流程成功                    | `task.completed`            |
| 任意 Worker         | 异常失败                      | `task.failed`               |

> ❌ 不再发布 `image.processed`，因为架构已移除图片变换功能。

---

### 事件结构标准

所有事件应遵循以下结构接口：

```ts
export interface INEvent<T = Record<string, any>> {
  eventId: string;           // 事件唯一标识 (UUID)
  eventType: string;         // 事件类型 (如 image.downloaded)
  taskId?: string;           // 可选，关联任务 ID
  traceId: string;           // 贯穿请求全链路的追踪 ID
  timestamp: number;         // 事件生成时间戳 (Unix 毫秒)
  source: string;            // 事件来源 Worker 名称
  payload: T;                // 事件实际内容
}
