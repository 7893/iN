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

# --- Cloudflare Workers Scripts (仅资源本身，无绑定) ---
resource "cloudflare_workers_script" "api_gateway" {
  account_id  = var.cloudflare_account_id
  script_name = "in-worker-a-api-gateway-20250402"
  content     = "addEventListener('fetch', event => { event.respondWith(new Response('API Gateway OK', { status: 200 })) })"
}
resource "cloudflare_workers_script" "config_api" {
  account_id  = var.cloudflare_account_id
  script_name = "in-worker-b-config-api-20250402"
  content     = "addEventListener('fetch', event => { event.respondWith(new Response('Config API OK', { status: 200 })) })"
}
resource "cloudflare_workers_script" "config" {
  account_id  = var.cloudflare_account_id
  script_name = "in-worker-c-config-20250402"
  content     = "addEventListener('fetch', event => { event.respondWith(new Response('Config Worker OK', { status: 200 })) })"
}
resource "cloudflare_workers_script" "download" {
  account_id  = var.cloudflare_account_id
  script_name = "in-worker-d-download-20250402"
  content     = "addEventListener('fetch', event => { event.respondWith(new Response('Download Worker OK', { status: 200 })) })"
}
resource "cloudflare_workers_script" "metadata" {
  account_id  = var.cloudflare_account_id
  script_name = "in-worker-e-metadata-20250402"
  content     = "addEventListener('fetch', event => { event.respondWith(new Response('Metadata Worker OK', { status: 200 })) })"
}
resource "cloudflare_workers_script" "ai" {
  account_id  = var.cloudflare_account_id
  script_name = "in-worker-f-ai-20250402"
  content     = "addEventListener('fetch', event => { event.respondWith(new Response('AI Worker OK', { status: 200 })) })"
}
resource "cloudflare_workers_script" "user_api" {
  account_id  = var.cloudflare_account_id
  script_name = "in-worker-g-user-api-20250402"
  content     = "addEventListener('fetch', event => { event.respondWith(new Response('User API OK', { status: 200 })) })"
}
resource "cloudflare_workers_script" "image_query_api" {
  account_id  = var.cloudflare_account_id
  script_name = "in-worker-h-image-query-api-20250402"
  content     = "addEventListener('fetch', event => { event.respondWith(new Response('Image Query API OK', { status: 200 })) })"
}
resource "cloudflare_workers_script" "image_mutation_api" {
  account_id  = var.cloudflare_account_id
  script_name = "in-worker-i-image-mutation-api-20250402"
  content     = "addEventListener('fetch', event => { event.respondWith(new Response('Image Mutation API OK', { status: 200 })) })"
}
resource "cloudflare_workers_script" "image_search_api" {
  account_id  = var.cloudflare_account_id
  script_name = "in-worker-j-image-search-api-20250402"
  content     = "addEventListener('fetch', event => { event.respondWith(new Response('Image Search API OK', { status: 200 })) })"
}

#resource "cloudflare_workers_script" "frontend_worker" {
#  account_id  = var.cloudflare_account_id
#  script_name = "in"
#  content     = "addEventListener('fetch', event => { event.respondWith(new Response('Worker [in] provisioned by Terraform - OK', { status: 200 })) })"
#}

# --- Cloudflare Pages 前端项目 ---
resource "cloudflare_pages_project" "frontend" {
  account_id        = var.cloudflare_account_id
  name              = "in"
  production_branch = var.pages_production_branch

  build_config = {
    build_command   = "pnpm install && pnpm build"
    destination_dir = "dist"
    root_dir        = "apps/in-pages"
  }
}


# --- 输出信息 ---
output "d1_database_id" {
  value = cloudflare_d1_database.main.id
}

output "all_worker_script_names" {
  value = [
    cloudflare_workers_script.api_gateway.script_name,
    cloudflare_workers_script.config_api.script_name,
    cloudflare_workers_script.config.script_name,
    cloudflare_workers_script.download.script_name,
    cloudflare_workers_script.metadata.script_name,
    cloudflare_workers_script.ai.script_name,
    cloudflare_workers_script.user_api.script_name,
    cloudflare_workers_script.image_query_api.script_name,
    cloudflare_workers_script.image_mutation_api.script_name,
    cloudflare_workers_script.image_search_api.script_name,
    #cloudflare_workers_script.frontend_worker.script_name,
  ]
}
