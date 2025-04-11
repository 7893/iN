# 事件类型清单

🎯 **目的:** 提供标准化的事件类型常量及其说明，供系统各处 Worker 在发布和订阅事件时统一引用。所有常量定义在 `packages/shared-libs/src/events/event-types.ts`。

| eventType                  | 发布者                                | 潜在消费者                                                   | 描述                                        | 关联队列                  |
|---------------------------|-------------------------------------|--------------------------------------------------------------|--------------------------------------------|--------------------------|
| `task.created`             | Config Worker / API Worker          | DownloadWorker, LoggerWorker, AnalyticsWorker               | 新任务创建并调度                            | TaskLifecycleEventsQueue |
| `image.downloaded`         | Download Worker                     | MetadataWorker, AnalyticsWorker, LoggerWorker               | 图片下载成功                                | ImageEventsQueue         |
| `image.processed`          | Image Processing Worker             | MetadataWorker, AnalyticsWorker                             | 图片已变换处理                              | ImageEventsQueue         |
| `image.metadata_extracted` | Metadata Worker                     | AIWorker, TagIndexerWorker                                  | 图片元数据提取完成                          | ImageEventsQueue         |
| `image.analyzed`           | AI Worker                           | NotificationWorker, AnalyticsWorker                         | 图片 AI 分析完成                            | ImageEventsQueue         |
| `task.completed`           | AI Worker                           | NotificationWorker, AnalyticsWorker                         | 整个任务成功完成                            | TaskLifecycleEventsQueue |
| `task.failed`              | 任意失败环节                        | NotificationWorker, ErrorReportingWorker, AnalyticsWorker   | 某阶段处理失败                              | TaskLifecycleEventsQueue |
| `plugin.executed`          | Plugin Worker / Runtime             | LoggerWorker, AnalyticsWorker                               | 插件执行完毕                                | PluginEventsQueue        |
