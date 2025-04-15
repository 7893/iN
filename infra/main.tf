# ~/iN/infra/main.tf - 已根据 Cloudflare Provider v5.x 语法修正

# --- D1 Database ---
resource "cloudflare_d1_database" "main" {
  account_id = var.cloudflare_account_id
  name       = "in-d1-a-database-20250402" # D1 的名称参数似乎未变
}

# --- R2 Bucket ---
resource "cloudflare_r2_bucket" "main" {
  account_id = var.cloudflare_account_id
  name       = "in-r2-a-bucket-20250402" # R2 的名称参数似乎未变
}

# --- Queues ---
resource "cloudflare_queue" "imagedownload_dlq" {
  account_id = var.cloudflare_account_id
  # --- v5: 使用 queue_name ---
  queue_name = "in-queue-b-image-download-dlq-20250402"
}
resource "cloudflare_queue" "metadataprocessing_dlq" {
  account_id = var.cloudflare_account_id
  # --- v5: 使用 queue_name ---
  queue_name = "in-queue-d-metadata-processing-dlq-20250402"
}
resource "cloudflare_queue" "aiprocessing_dlq" {
  account_id = var.cloudflare_account_id
  # --- v5: 使用 queue_name ---
  queue_name = "in-queue-f-ai-processing-dlq-20250402"
}
resource "cloudflare_queue" "imagedownload" {
  account_id = var.cloudflare_account_id
  # --- v5: 使用 queue_name ---
  queue_name = "in-queue-a-image-download-20250402"
}
resource "cloudflare_queue" "metadataprocessing" {
  account_id = var.cloudflare_account_id
  # --- v5: 使用 queue_name ---
  queue_name = "in-queue-c-metadata-processing-20250402"
}
resource "cloudflare_queue" "aiprocessing" {
  account_id = var.cloudflare_account_id
  # --- v5: 使用 queue_name ---
  queue_name = "in-queue-e-ai-processing-20250402"
}

# --- Workers ---
# 注意：所有 name 参数已改为 script_name
resource "cloudflare_workers_script" "api_gateway" {
  account_id = var.cloudflare_account_id
  # --- v5: 使用 script_name ---
  script_name = "in-worker-a-api-gateway-20250402"
  content     = "addEventListener('fetch', event => { event.respondWith(new Response('OK', { status: 200 })) })" # 临时内容
}
resource "cloudflare_workers_script" "config_api" {
  account_id = var.cloudflare_account_id
  # --- v5: 使用 script_name ---
  script_name = "in-worker-b-config-api-20250402"
  content     = "addEventListener('fetch', event => { event.respondWith(new Response('OK', { status: 200 })) })" # 临时内容
}
resource "cloudflare_workers_script" "config" {
  account_id = var.cloudflare_account_id
  # --- v5: 使用 script_name ---
  script_name = "in-worker-c-config-20250402"
  content     = "addEventListener('fetch', event => { event.respondWith(new Response('OK', { status: 200 })) })" # 临时内容
}
resource "cloudflare_workers_script" "download" {
  account_id = var.cloudflare_account_id
  # --- v5: 使用 script_name ---
  script_name = "in-worker-d-download-20250402"
  content     = "addEventListener('fetch', event => { event.respondWith(new Response('OK', { status: 200 })) })" # 临时内容
}
resource "cloudflare_workers_script" "metadata" {
  account_id = var.cloudflare_account_id
  # --- v5: 使用 script_name ---
  script_name = "in-worker-e-metadata-20250402"
  content     = "addEventListener('fetch', event => { event.respondWith(new Response('OK', { status: 200 })) })" # 临时内容
}
resource "cloudflare_workers_script" "ai" {
  account_id = var.cloudflare_account_id
  # --- v5: 使用 script_name ---
  script_name = "in-worker-f-ai-20250402"
  content     = "addEventListener('fetch', event => { event.respondWith(new Response('OK', { status: 200 })) })" # 临时内容
}
resource "cloudflare_workers_script" "user_api" {
  account_id = var.cloudflare_account_id
  # --- v5: 使用 script_name ---
  script_name = "in-worker-g-user-api-20250402"
  content     = "addEventListener('fetch', event => { event.respondWith(new Response('OK', { status: 200 })) })" # 临时内容
}
resource "cloudflare_workers_script" "image_query_api" {
  account_id = var.cloudflare_account_id
  # --- v5: 使用 script_name ---
  script_name = "in-worker-h-image-query-api-20250402"
  content     = "addEventListener('fetch', event => { event.respondWith(new Response('OK', { status: 200 })) })" # 临时内容
}
resource "cloudflare_workers_script" "image_mutation_api" {
  account_id = var.cloudflare_account_id
  # --- v5: 使用 script_name ---
  script_name = "in-worker-i-image-mutation-api-20250402"
  content     = "addEventListener('fetch', event => { event.respondWith(new Response('OK', { status: 200 })) })" # 临时内容
}
resource "cloudflare_workers_script" "image_search_api" {
  account_id = var.cloudflare_account_id
  # --- v5: 使用 script_name ---
  script_name = "in-worker-j-image-search-api-20250402"
  content     = "addEventListener('fetch', event => { event.respondWith(new Response('OK', { status: 200 })) })" # 临时内容
}

# --- Pages ---
resource "cloudflare_pages_project" "frontend" {
  account_id        = var.cloudflare_account_id
  name              = "in-pages"
  production_branch = var.pages_production_branch
}

# --- Outputs (可选) ---
output "d1_database_id" { value = cloudflare_d1_database.main.id }
output "r2_bucket_name" { value = cloudflare_r2_bucket.main.name }
# output "pages_url" { value = cloudflare_pages_project.frontend.url } # url 可能在 v5 中获取方式有变化