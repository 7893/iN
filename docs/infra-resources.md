# iN 项目基础设施资源清单（仅名称）

## 💻 Workers（共 10 个）

- `iN-worker-api-gateway`
- `iN-worker-config-api`
- `iN-worker-config`
- `iN-worker-download`
- `iN-worker-metadata`
- `iN-worker-ai`
- `iN-worker-user-api`
- `iN-worker-image-query-api`
- `iN-worker-image-mutation-api`
- `iN-worker-image-search-api`

## 📬 Queues（共 6 个，包括 DLQs）

- `iN-queue-imagedownload`
- `iN-queue-imagedownload-dlq`
- `iN-queue-metadataprocessing`
- `iN-queue-metadataprocessing-dlq`
- `iN-queue-aiprocessing`
- `iN-queue-aiprocessing-dlq`

## 🧠 Durable Object Bindings

- `iN-do-task-coordinator`

## 🗃️ Storage（共 3 个）

- `iN-r2-bucket`
- `iN-d1-database`
- `iN-vectorize-index`

## 🌐 前端与日志

- `iN-pages-frontend`
- `iN-logpush-axiom`
