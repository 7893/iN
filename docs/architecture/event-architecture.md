## 混合事件驱动架构 (Hybrid Event-Driven Architecture)

🎯 **目的:** 解释本项目采用“任务队列 + 事件队列”混合模式的原因，定义事件的标准化结构、不同队列的用途以及事件的命名规范。

### 为什么采用任务 + 事件混合模式？

纯粹的事件驱动架构（所有交互通过事件解耦）提供了极高的灵活性和可扩展性，但可能导致端到端业务流程难以追踪、分布式调试复杂、最终一致性管理困难。而纯粹的任务队列驱动则缺乏广播能力，难以灵活地增加对流程中某些状态变更感兴趣的“副作用”处理逻辑（如通知、统计、索引等）。

本项目采用**混合模式**旨在结合两者的优点：

1.  **核心流程清晰可控:** 对于图片处理这种具有明确先后顺序的核心业务流程（下载 -> 元数据 -> AI），我们继续使用**任务队列 (Task Queues)** 来驱动。这使得主流程的状态可以通过 `Task Coordinator DO` 清晰地跟踪，便于管理和理解。
2.  **副作用灵活解耦:** 对于核心流程中产生的关键**里程碑事件**（如“图片下载完成”、“任务处理成功/失败”）或系统中其他可能被多个独立模块关注的状态变化，我们使用**事件队列 (Event Queues)** 来进行广播。这样，添加新的响应逻辑（如发送通知、更新统计、触发特定插件）时，只需让新的 Worker 订阅相应的事件队列即可，无需修改核心流程代码，实现了高度解耦和扩展性。
3.  **平衡复杂度:** 这种方式避免了所有交互都依赖事件可能带来的过度复杂性，将复杂性控制在需要灵活扩展的“副作用”处理上，而核心流程保持相对简单直接。

### 队列用途定义

- **任务队列 (Task Queues):**
  - **用途:** 传递**指令性**消息，驱动核心业务流程按预定顺序执行下一步。
  - **示例:** `ImageDownloadQueue`, `MetadataProcessingQueue`, `AIProcessingQueue`
  - **消费者:** 通常是**单一类型**的 Worker，负责执行该任务指令。
  - **状态关联:** 处理 Task Queue 的 Worker 通常负责更新 `Task Coordinator DO` 中对应的任务**主流程状态**。

- **事件队列 (Event Queues):**
  - **用途:** 广播**事实性**消息，通知系统中发生了某个重要的里程碑事件或状态变更。
  - **示例:** `ImageEventsQueue`, `TaskLifecycleEventsQueue`
  - **消费者:** 可以是**多种不同类型**的 Worker（通知、统计、索引、插件等），它们各自独立地对感兴趣的事件做出响应。
  - **状态关联:** 订阅 Event Queue 的 Worker **通常不**更新 `Task Coordinator DO` 的主流程状态，它们处理的是独立的副作用逻辑。事件流的追踪主要依赖日志和 `traceId`。

### 发布事件的时机 (示例)

- `DownloadWorker` 完成图片下载 -> 发布 `image.downloaded`
- `MetadataWorker` 提取元数据 -> 发布 `image.metadata_extracted`
- `AIWorker` 生成向量化分析 -> 发布 `image.analyzed`
- 最后完成任务 -> 发布 `task.completed`
- 任意失败 -> 发布 `task.failed`

### 事件结构约定

```ts
export interface INEvent<T = Record<string, any>> {
  eventId: string;
  eventType: string;
  taskId?: string;
  traceId: string;
  timestamp: number;
  source: string;
  payload: T;
}
