# ~/iN/infra/vectorize/main.tf (或 vectorize.tf) - 简化版尝试

resource "cloudflare_vectorize_index" "main" {
  account_id = var.cloudflare_account_id
  name       = var.index_name # "in-vectorize-a-index-20250402"

  # 只保留最核心的 config 块 (使用 preset)
  config {
    preset = var.vectorize_preset # 例如 "@cf/baai/bge-small-en-v1.5"
  }

  # 暂时移除其他可选参数如 description
}

# --- 可选输出 ---
output "index_name" {
  description = "The name of the Vectorize index"
  value       = cloudflare_vectorize_index.main.name
}