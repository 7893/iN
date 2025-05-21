# ☑️ GCP Pub/Sub 死信主题 (Dead-Letter Topic) 处理指南 (架构版本 2025年5月21日)

## 🧩 背景

在基于 Google Cloud Pub/Sub 的异步消息驱动架构中，当订阅者（例如 GCP Cloud Function/Run 服务）多次尝试处理某条消息失败后，为了避免消息丢失并阻塞主处理流程，Pub/Sub 允许将这些无法成功处理的消息转发到一个指定的“死信主题”(Dead-Letter Topic, DLT)。本指南旨在设计 iN 项目中 DLT 消息的处理机制。

## ✅ 核心机制与 GCP Pub/Sub 死信特性

1.  **配置死信策略**:
    * 为项目中的每个核心 Pub/Sub 订阅（例如，`in-pubsub-sub-download-trigger`, `in-pubsub-sub-metadata-trigger` 等）配置一个死信策略。
    * 策略中定义：
        * **死信主题 (DLT)**: 一个专门用于接收死信的 Pub/Sub 主题 (例如 `in-pubsub-dlt-download-requests`)。
        * **最大投递尝试次数**: 原始订阅在将消息发送到 DLT 之前尝试投递给订阅者的最大次数 (例如 5 到 10 次)。

2.  **死信主题 (DLT) 的订阅与处理**:
    * 为每个 DLT 创建一个或多个订阅。
    * 这些订阅可以被以下服务消费：
        * **日志记录与告警服务**: 一个简单的 Cloud Function 可以订阅所有 DLTs，将接收到的死信消息的元数据（如原始消息ID、错误属性、时间戳）和部分负载（注意脱敏）记录到 Google Cloud Logging，并在 GCP Monitoring 中触发告警。
        * **人工审查与干预界面 (可选)**: 可以构建一个简单的内部工具或利用 GCP 控制台查看 DLT 中的消息，供开发或运维人员分析失败原因。
        * **自动重放/修复逻辑 (谨慎使用)**: 针对某些已知可自动修复的错误，可以编写一个专门的 Cloud Function/Run 服务尝试修复消息内容或依赖条件后，重新将其发布回原始主流程的入口主题。此操作需非常谨慎，并有熔断机制。

3.  **死信消息的属性**:
    * 转发到 DLT 的消息会保留原始消息的大部分属性，并由 Pub/Sub 添加一些额外属性来标明其来源、尝试次数等，便于追踪和分析。例如：
        * `googclient_deliveryattempt` (原始订阅的投递尝试次数)
        * 原始消息的 `messageId`, `publishTime`, `attributes`, `orderingKey` (如果使用)。

## 🔁 建议的死信处理流程 (MVP)

1.  **启用并配置 DLT**: 为所有关键业务流程的 Pub/Sub 订阅配置好指向相应 DLTs 的死信策略。
2.  **统一死信日志记录**:
    * 创建一个专用的 Cloud Function (`in-function-dlt-logger`)。
    * 此 Function 订阅所有项目的 DLTs (可以使用一个通配符订阅，或分别为每个 DLT 创建订阅并指向同一个 Function)。
    * 当接收到死信时，该 Function 将消息的关键信息（脱敏后）结构化地记录到 Google Cloud Logging。
3.  **GCP Monitoring 告警**:
    * 在 GCP Monitoring 中基于 Cloud Logging 的日志指标创建告警策略。
    * 例如，当 DLT 日志记录Function在特定时间窗口内处理的消息数量超过阈值时，发送告警通知。
    * 监控 DLTs 对应的订阅的 `num_undelivered_messages` (未确认消息数) 指标，如果持续偏高则告警。
4.  **手动审查 (初期)**:
    * 开发/运维人员定期通过 GCP 控制台检查各 DLTs 的消息积压情况。
    * 根据日志分析失败原因，手动处理或决定是否需要重放。

## 🔮 未来增强

* **死信消息归档**: 将长时间未处理的死信从 DLT 归档到 Google Cloud Storage (GCS) 以降低 Pub/Sub 存储成本。
* **部分自动化重试**: 针对特定错误类型（例如，可识别的瞬时依赖服务不可用），开发小工具或 Function 尝试有条件地重放消息。
* **失败模式分析**: 定期分析 DLT 中的消息，识别常见的失败模式，用以改进主流程代码的健壮性。

---
文件名：dlq-handling-guide-20250521.md (原 dlq-handling-guide-20250422.md)
生成时间：20250521 (根据实际更新时间调整)