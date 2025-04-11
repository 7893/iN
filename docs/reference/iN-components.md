# iN 项目组件清单

## 1. Workers（功能执行单元）

- `api-gateway-worker`
- `user-api-worker`
- `image-query-api-worker`
- `image-mutation-api-worker`
- `image-search-api-worker`
- `config-api-worker`
- `config-worker`
- `download-worker`
- `metadata-worker`
- `ai-worker`
- `image-processing-worker`（可选，用于 Resize / Watermark）
- `image-update-worker`（可选，用于最终状态聚合或通知）
- `notification-worker`（可选，事件订阅者）
- `analytics-worker`（可选，事件订阅者）
- `tag-indexer-worker`（可选，事件订阅者）
- （其他未来可扩展订阅者 Worker）

## 2. Queues（消息队列）

### 核心任务队列（Task Queues）+ DLQs

- `ImageDownloadQueue` / `ImageDownloadQueue_DLQ`
- `MetadataProcessingQueue` / `MetadataProcessingQueue_DLQ`
- `AIProcessingQueue` / `AIProcessingQueue_DLQ`
- `ImageProcessingQueue` / `ImageProcessingQueue_DLQ`（可选）

### 控制类任务队列（可选）+ DLQs

- `ImageUpdateNotificationQueue` / `ImageUpdateNotificationQueue_DLQ`
- `TaskControlQueue` / `TaskControlQueue_DLQ`

### 事件队列（Event Queues）+ DLQs

- `ImageEventsQueue` / `ImageEventsQueue_DLQ`
- `TaskLifecycleEventsQueue` / `TaskLifecycleEventsQueue_DLQ`

## 3. Durable Objects（DO）

- `Task Coordinator DO`（按 taskId 分片，管理任务状态）

## 4. R2（对象存储）

- `iN_R2_Bucket`（用于存储图片原始与处理文件）

## 5. D1（结构化数据库）

- `iN_D1_Database`（存储用户配置、元数据、分析结果等）

## 6. Vectorize（向量数据库）

- `iN_Vectorize_Index`（图片向量嵌入索引，用于搜索）

