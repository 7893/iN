# ~/iN/infra/workers/main.tf (或 workers.tf) - 已将 Worker 名称改为全小写

resource "cloudflare_workers_script" "api_gateway" {
  account_id = var.cloudflare_account_id
  # --- 名称已改为全小写 ---
  name       = "in-worker-a-api-gateway-20250402"
  content    = "addEventListener('fetch', event => { event.respondWith(new Response('OK', { status: 200 })) })" # 临时内容
  # ... 其他绑定注释 ...
}

resource "cloudflare_workers_script" "config_api" {
  account_id = var.cloudflare_account_id
  # --- 名称已改为全小写 ---
  name       = "in-worker-b-config-api-20250402"
  content    = "addEventListener('fetch', event => { event.respondWith(new Response('OK', { status: 200 })) })" # 临时内容
}

resource "cloudflare_workers_script" "config" {
  account_id = var.cloudflare_account_id
  # --- 名称已改为全小写 ---
  name       = "in-worker-c-config-20250402"
  content    = "addEventListener('fetch', event => { event.respondWith(new Response('OK', { status: 200 })) })" # 临时内容
}

resource "cloudflare_workers_script" "download" {
  account_id = var.cloudflare_account_id
  # --- 名称已改为全小写 ---
  name       = "in-worker-d-download-20250402"
  content    = "addEventListener('fetch', event => { event.respondWith(new Response('OK', { status: 200 })) })" # 临时内容
}

resource "cloudflare_workers_script" "metadata" {
  account_id = var.cloudflare_account_id
  # --- 名称已改为全小写 ---
  name       = "in-worker-e-metadata-20250402"
  content    = "addEventListener('fetch', event => { event.respondWith(new Response('OK', { status: 200 })) })" # 临时内容
}

resource "cloudflare_workers_script" "ai" {
  account_id = var.cloudflare_account_id
  # --- 名称已改为全小写 ---
  name       = "in-worker-f-ai-20250402"
  content    = "addEventListener('fetch', event => { event.respondWith(new Response('OK', { status: 200 })) })" # 临时内容
}

resource "cloudflare_workers_script" "user_api" {
  account_id = var.cloudflare_account_id
  # --- 名称已改为全小写 ---
  name       = "in-worker-g-user-api-20250402"
  content    = "addEventListener('fetch', event => { event.respondWith(new Response('OK', { status: 200 })) })" # 临时内容
}

resource "cloudflare_workers_script" "image_query_api" {
  account_id = var.cloudflare_account_id
  # --- 名称已改为全小写 ---
  name       = "in-worker-h-image-query-api-20250402"
  content    = "addEventListener('fetch', event => { event.respondWith(new Response('OK', { status: 200 })) })" # 临时内容
}

resource "cloudflare_workers_script" "image_mutation_api" {
  account_id = var.cloudflare_account_id
  # --- 名称已改为全小写 ---
  name       = "in-worker-i-image-mutation-api-20250402"
  content    = "addEventListener('fetch', event => { event.respondWith(new Response('OK', { status: 200 })) })" # 临时内容
}

resource "cloudflare_workers_script" "image_search_api" {
  account_id = var.cloudflare_account_id
  # --- 名称已改为全小写 ---
  name       = "in-worker-j-image-search-api-20250402"
  content    = "addEventListener('fetch', event => { event.respondWith(new Response('OK', { status: 200 })) })" # 临时内容
}