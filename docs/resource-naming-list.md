# iN 项目基础设施资源命名清单
当前时间: 2025-04-11 05:27:54 UTC  
命名规范: `iN-<类型>-<标识>-20250402`

---

## ✅ Cloudflare Infrastructure Resource Names (按建立顺序)

### 🧠 Workers（10 个）

```
iN-worker-A-api-gateway-20250402
iN-worker-B-config-api-20250402
iN-worker-C-config-20250402
iN-worker-D-download-20250402
iN-worker-E-metadata-20250402
iN-worker-F-ai-20250402
iN-worker-G-user-api-20250402
iN-worker-H-image-query-api-20250402
iN-worker-I-image-mutation-api-20250402
iN-worker-J-image-search-api-20250402
```

---

### 📬 Queues + DLQs（6 对）

```
iN-queue-A-image-download-20250402
iN-queue-B-image-download-dlq-20250402
iN-queue-C-metadata-processing-20250402
iN-queue-D-metadata-processing-dlq-20250402
iN-queue-E-ai-processing-20250402
iN-queue-F-ai-processing-dlq-20250402
```

---

### 🧱 Durable Object Bindings（1 个）

```
iN-do-A-task-coordinator-20250402
```

---

### 🗃️ Storage 资源（3 个）

```
iN-r2-A-bucket-20250402
iN-d1-A-database-20250402
iN-vectorize-A-index-20250402
```

---

### 🌐 Cloudflare Pages（1 个）

```
in-pages
```

---

### 📊 Logpush（1 个）

```
iN-logpush-A-axiom-20250402
```
