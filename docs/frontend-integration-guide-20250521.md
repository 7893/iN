# 🔁 前端整合指南 (架构版本 2025年5月21日)
_Vercel 前端与 Cloudflare API Gateway 及 GCP 认证的联调说明与 API 对接建议_

## 🌉 前后端联通目标

- **用户认证**: 前端应用 (部署于 Vercel) 需能引导用户通过 **Google Cloud Identity Platform (GCIP)** 完成登录认证流程，并获取 ID Token。
- **任务配置与触发**: 用户在前端页面配置图像处理任务参数，并通过调用部署在 **Cloudflare Workers 上的 API Gateway** 发起任务创建请求。
- **状态查询与结果展示**: 前端页面能够查询已创建任务的处理状态和最终结果（包括 AI 分析标签、相似图片等，如果实现了向量搜索）。
- **向量搜索 (如果实现)**: 支持用户在前端页面发起基于文本描述的图像查询请求，并展示搜索结果。

## ✅ 核心 API 接口 (由 Cloudflare API Gateway Worker 提供)

所有 API 请求均需携带由 GCIP 签发的有效 ID Token (作为 `Authorization: Bearer <ID_TOKEN>` HTTP头部)。

1.  **任务创建 API**:
    * **路径**: `/api/tasks` (示例)
    * **方法**: `POST`
    * **请求体 (示例 JSON)**:
      ```json
      {
        "sourceImageUrl": "[https://example.com/image.jpg](https://example.com/image.jpg)",
        "processingOptions": { // 特定于任务的配置项
          "generateThumbnail": true,
          "aiAnalysisLevel": "detailed"
        }
        // ... 其他用户可配置参数
      }
      ```
    * **成功响应 (示例 `202 Accepted`)**:
      ```json
      {
        "taskId": "task-uuid-12345",
        "message": "Task submitted successfully. Processing started.",
        "statusQueryUrl": "/api/tasks/task-uuid-12345/status" // 可选，方便客户端查询状态
      }
      ```
    * **后端逻辑**: Cloudflare API Gateway Worker 验证 GCIP ID Token，校验请求参数，初始化 `TaskCoordinatorDO`，并将任务信息发布到 GCP Pub/Sub 的初始主题。

2.  **任务状态查询 API**:
    * **路径**: `/api/tasks/{taskId}/status` (示例)
    * **方法**: `GET`
    * **成功响应 (示例 `200 OK`)**:
      ```json
      {
        "taskId": "task-uuid-12345",
        "overallStatus": "processing | completed | failed", // 例如: "metadata.extracted", "ai.analyzed"
        "currentStage": "ai.analysis.initiated", // 当前或最后处理的阶段
        "createdAt": "2025-05-21T10:00:00Z",
        "updatedAt": "2025-05-21T10:05:00Z",
        "errorInfo": null, // 如果失败，则包含错误信息
        "results": { // 如果任务完成，可能包含结果摘要或链接
          "processedImageKey_R2": "r2_bucket/processed/image.jpg",
          "metadata": { "width": 1920, "height": 1080 },
          "aiTags": ["dog", "animal", "outdoor"]
        }
      }
      ```
    * **后端逻辑**: Cloudflare API Gateway Worker 验证 GCIP ID Token，从路径中获取 `taskId`，然后调用 `TaskCoordinatorDO` 的状态查询接口。

3.  **图像向量搜索 API (如果实现)**:
    * **路径**: `/api/images/search` (示例)
    * **方法**: `POST` (或 `GET` 如果查询参数简单)
    * **请求体 (示例 JSON for POST)**:
      ```json
      {
        "queryText": "a dog playing in the park",
        "limit": 10,
        "filters": { // 可选的过滤条件
          "minDate": "2024-01-01"
        }
      }
      ```
    * **成功响应 (示例 `200 OK`)**:
      ```json
      {
        "query": "a dog playing in the park",
        "results": [
          {
            "imageUrl": "https://<your-r2-public-url-or-cf-worker-url>/r2_bucket/path/to/image1.jpg", // 或GCS公共URL
            "score": 0.97,
            "tags": ["dog", "animal", "park", "playing"]
          }
          // ...更多结果
        ]
      }
      ```
    * **后端逻辑**: Cloudflare API Gateway Worker 验证 GCIP ID Token，将文本查询转换为向量（可能通过调用一个专用的 GCP Function/Cloud Run 服务或 Cloudflare Worker），然后查询 Cloudflare Vectorize（或 GCP Vertex AI Vector Search）索引。

## 🔍 搜索类型 (基于 `frontend-integration-guide-20250422.md`)

- 基于文本描述（调用向量索引服务）。
- (未来可选) 基于相似图片。

## 💡 联调建议

- **认证先行**: 首先确保 Vercel 前端能正确集成 Google Cloud Identity Platform (GCIP) 的客户端 SDK，完成用户登录并获取 ID Token。
- **API 客户端封装**: 在前端项目中创建一个统一的 API 客户端模块 (`utils/apiClient.ts` 或类似)，负责：
    * 自动从 GCIP SDK 获取并附加 `Authorization: Bearer <ID_TOKEN>` 到每个请求头。
    * 处理 Token 过期和刷新逻辑（GCIP SDK 通常会辅助处理）。
    * 统一处理 API 错误响应（如 401, 403, 500 等）。
    * 封装各个 API 端点的调用方法。
- **环境变量**: Vercel 项目中配置 Cloudflare API Gateway 的基础 URL 作为环境变量 (例如 `NEXT_PUBLIC_API_BASE_URL`)。
- **TraceID 传递**: 前端在发起 API 请求时，如果可能，生成一个 `traceId` (例如 UUID v4) 并通过自定义请求头（如 `X-Trace-Id`）传递给 Cloudflare API Gateway Worker，以便于后端进行全链路日志追踪。
- **CORS 配置**: 确保 Cloudflare API Gateway Worker 正确配置了 CORS (Cross-Origin Resource Sharing) 策略，允许来自 Vercel 部署域名的跨域请求。
- **Mocking**: 在前端开发早期，可以使用 MSW (Mock Service Worker) 或类似工具模拟 Cloudflare API Gateway 的响应，以便独立于后端进行开发。
- **逐步联调**:
    1.  用户认证流程。
    2.  任务创建 API。
    3.  任务状态查询 API (初期可能状态更新较慢，需要耐心等待或轮询)。
    4.  (如果实现) 图像搜索 API。

## 🎨 页面建议 (基于 `frontend-integration-guide-20250422.md`)

- **登录页面**: 使用 GCIP 提供的登录方式。
- **任务配置/输入页面**: 提供表单让用户输入图片源、处理选项等。
- **任务状态列表/仪表盘页面**: 显示用户已提交任务的列表及其当前状态，支持点击查看详情。
- **图像搜索页面**: 输入框 + 查询按钮，查询结果以网格或列表形式展示。
- **通用**: 支持加载状态 (loading indicators) 和空状态/错误状态的友好提示。

通过以上步骤，可以实现 Vercel 前端与 Cloudflare API Gateway Worker 及背后 GCP 驱动的异步处理流程的顺畅集成。