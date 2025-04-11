# iN 项目资源名称列表

**当前时间**: 2025年4月10日 星期四  
**地点**: 韩国

以下是最终的资源名称列表（仅列出名称），基于所有讨论和决策，反映了 Cloudflare Pages 名称简化为 `in-pages` 且不使用数字后缀的调整。

## 资源分类及个数

- **Workers**: 15 个
- **Queues**: 16 个
- **Durable Objects**: 1 个 (注：这是 Durable Object 类的定义，实际运行时会有多个实例)
- **R2**: 1 个
- **D1**: 1 个
- **Vectorize**: 1 个
- **Cloudflare Pages**: 1 个
- **Cloudflare Logpush**: 1 个

## 资源名称列表

### Workers (15 个)

- iN-worker-A-api-gateway-20250402
- iN-worker-B-config-api-20250402
- iN-worker-C-config-20250402
- iN-worker-D-download-20250402
- iN-worker-E-metadata-20250402
- iN-worker-F-ai-20250402
- iN-worker-G-user-api-20250402
- iN-worker-H-image-query-api-20250402
- iN-worker-I-image-mutation-api-20250402
- iN-worker-J-image-search-api-20250402
- iN-worker-K-ai-20250402
- iN-worker-L-notification-20250402
- iN-worker-M-tag-indexer-20250402
- iN-worker-N-analytics-20250402
- iN-worker-O-image-update-20250402

### Queues (16 个)

- iN-queue-A-imagedownload-20250402
- iN-queue-B-imagedownload-dlq-20250402
- iN-queue-C-metadataprocessing-20250402
- iN-queue-D-metadataprocessing-dlq-20250402
- iN-queue-E-aiprocessing-20250402
- iN-queue-F-aiprocessing-dlq-20250402
- iN-queue-G-imageevents-20250402
- iN-queue-H-imageevents-dlq-20250402
- iN-queue-I-tasklifecycleevents-20250402
- iN-queue-J-tasklifecycleevents-dlq-20250402
- iN-queue-K-imageprocessing-20250402
- iN-queue-L-imageprocessing-dlq-20250402
- iN-queue-M-imageupdatenotification-20250402
- iN-queue-N-imageupdatenotification-dlq-20250402
- iN-queue-O-taskcontrol-20250402
- iN-queue-P-taskcontrol-dlq-20250402

### Durable Objects (1 个)

- iN-do-A-task-coordinator-binding-20250402

### R2 (1 个)

- iN-r2-A-bucket-20250402

### D1 (1 个)

- iN-d1-A-database-20250402

### Vectorize (1 个)

- iN-vectorize-A-index-20250402

### Cloudflare Pages (1 个)

- in-pages

### Cloudflare Logpush (1 个)

- iN-logpush-A-axiom-20250402

**说明**:  
- 已将 Cloudflare Pages 的名称更新为 `in-pages`，并去掉了日期后缀。  
- 请在 Terraform 配置文件中使用这些最终名称。