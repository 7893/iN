# ~/iN/infra/queues/main.tf (或 queues.tf) - 已移除 dlq 块, 名称使用小写标识

# --- Dead Letter Queues (DLQs) ---
resource "cloudflare_queue" "imagedownload_dlq" {
  account_id = var.cloudflare_account_id
  name       = "in-queue-b-image-download-dlq-20250402"
}

resource "cloudflare_queue" "metadataprocessing_dlq" {
  account_id = var.cloudflare_account_id
  name       = "in-queue-d-metadata-processing-dlq-20250402"
}

resource "cloudflare_queue" "aiprocessing_dlq" {
  account_id = var.cloudflare_account_id
  name       = "in-queue-f-ai-processing-dlq-20250402"
}


# --- Main Queues ---
resource "cloudflare_queue" "imagedownload" {
  account_id = var.cloudflare_account_id
  name       = "in-queue-a-image-download-20250402"
  # --- dlq 块已移除 ---
}

resource "cloudflare_queue" "metadataprocessing" {
  account_id = var.cloudflare_account_id
  name       = "in-queue-c-metadata-processing-20250402"
  # --- dlq 块已移除 ---
}

resource "cloudflare_queue" "aiprocessing" {
  account_id = var.cloudflare_account_id
  name       = "in-queue-e-ai-processing-20250402"
  # --- dlq 块已移除 ---
}

# --- 可选输出 ---
# output "queue_ids" { ... }