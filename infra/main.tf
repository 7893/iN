# ~/iN/infra/main.tf - 修复后的最终版本，兼容 Terraform v1.11 + Cloudflare Provider v5.3.0

# --- Cloudflare D1 数据库 ---
resource "cloudflare_d1_database" "main" {
  account_id = var.cloudflare_account_id
  name       = "in-d1-a-database-20250402"
}

# --- Cloudflare Queues ---
resource "cloudflare_queue" "imagedownload_dlq" {
  account_id = var.cloudflare_account_id
  queue_name = "in-queue-b-image-download-dlq-20250402"
}
resource "cloudflare_queue" "metadataprocessing_dlq" {
  account_id = var.cloudflare_account_id
  queue_name = "in-queue-d-metadata-processing-dlq-20250402"
}
resource "cloudflare_queue" "aiprocessing_dlq" {
  account_id = var.cloudflare_account_id
  queue_name = "in-queue-f-ai-processing-dlq-20250402"
}
resource "cloudflare_queue" "imagedownload" {
  account_id = var.cloudflare_account_id
  queue_name = "in-queue-a-image-download-20250402"
}
resource "cloudflare_queue" "metadataprocessing" {
  account_id = var.cloudflare_account_id
  queue_name = "in-queue-c-metadata-processing-20250402"
}
resource "cloudflare_queue" "aiprocessing" {
  account_id = var.cloudflare_account_id
  queue_name = "in-queue-e-ai-processing-20250402"
}

# --- Cloudflare Workers Scripts ---
resource "cloudflare_workers_script" "api_gateway" {
  account_id  = var.cloudflare_account_id
  script_name = "in-worker-a-api-gateway-20250402"
  content     = "addEventListener('fetch', event => { event.respondWith(new Response('OK', { status: 200 })) })"
}
resource "cloudflare_workers_script" "config_api" {
  account_id  = var.cloudflare_account_id
  script_name = "in-worker-b-config-api-20250402"
  content     = "addEventListener('fetch', event => { event.respondWith(new Response('OK', { status: 200 })) })"
}
resource "cloudflare_workers_script" "config" {
  account_id  = var.cloudflare_account_id
  script_name = "in-worker-c-config-20250402"
  content     = "addEventListener('fetch', event => { event.respondWith(new Response('OK', { status: 200 })) })"
}
resource "cloudflare_workers_script" "download" {
  account_id  = var.cloudflare_account_id
  script_name = "in-worker-d-download-20250402"
  content     = "addEventListener('fetch', event => { event.respondWith(new Response('OK', { status: 200 })) })"
}
resource "cloudflare_workers_script" "metadata" {
  account_id  = var.cloudflare_account_id
  script_name = "in-worker-e-metadata-20250402"
  content     = "addEventListener('fetch', event => { event.respondWith(new Response('OK', { status: 200 })) })"
}
resource "cloudflare_workers_script" "ai" {
  account_id  = var.cloudflare_account_id
  script_name = "in-worker-f-ai-20250402"
  content     = "addEventListener('fetch', event => { event.respondWith(new Response('OK', { status: 200 })) })"
}
resource "cloudflare_workers_script" "user_api" {
  account_id  = var.cloudflare_account_id
  script_name = "in-worker-g-user-api-20250402"
  content     = "addEventListener('fetch', event => { event.respondWith(new Response('OK', { status: 200 })) })"
}
resource "cloudflare_workers_script" "image_query_api" {
  account_id  = var.cloudflare_account_id
  script_name = "in-worker-h-image-query-api-20250402"
  content     = "addEventListener('fetch', event => { event.respondWith(new Response('OK', { status: 200 })) })"
}
resource "cloudflare_workers_script" "image_mutation_api" {
  account_id  = var.cloudflare_account_id
  script_name = "in-worker-i-image-mutation-api-20250402"
  content     = "addEventListener('fetch', event => { event.respondWith(new Response('OK', { status: 200 })) })"
}
resource "cloudflare_workers_script" "image_search_api" {
  account_id  = var.cloudflare_account_id
  script_name = "in-worker-j-image-search-api-20250402"
  content     = "addEventListener('fetch', event => { event.respondWith(new Response('OK', { status: 200 })) })"
}

resource "cloudflare_workers_script" "frontend_worker" { # Terraform 内部资源名，可以自定
  account_id = var.cloudflare_account_id
  # script_name: 部署到 Cloudflare 的服务名称，决定了 URL (in.53.workers.dev)
  script_name = "in"
  # content: 初始占位符，后续由 wrangler deploy 覆盖
  content     = "addEventListener('fetch', event => { event.respondWith(new Response('Frontend Worker Coming Soon!', { status: 200 })) })"
  # 注意：此 Worker 的绑定（例如，如果它需要调用 API Gateway）将在 apps/in/wrangler.toml 中定义
}

resource "cloudflare_workers_script" "frontend_in_worker" { # 这是 Terraform 内部的资源名称，可以自定义
  account_id = var.cloudflare_account_id # 从 variables.tf 引用账户 ID

  # script_name: 这是部署到 Cloudflare 上的服务名称，必须是 "in"
  script_name = "in"

  # content: 初始的占位符脚本内容。
  # 实际的前端代码和静态文件将由 Wrangler (在 CI/CD 中) 部署时覆盖。
  content    = "addEventListener('fetch', event => { event.respondWith(new Response('Worker [in] provisioned by Terraform - OK', { status: 200 })) })"

  # 注意：所有运行时绑定 (如果这个 Worker 需要的话，比如调用 API Gateway)
  # 都将在 apps/in/wrangler.toml 文件中定义，不由 Terraform 管理。
}

# --- 输出信息 ---
output "d1_database_id" {
  value = cloudflare_d1_database.main.id
}
