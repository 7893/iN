# ~/iN/infra/r2/main.tf (或 r2.tf)

resource "cloudflare_r2_bucket" "main" {
  account_id = var.cloudflare_account_id
  # 使用从根模块传入的小写标识名称
  name       = var.bucket_name
  # location_hint = "auto" # Or specify a location like "apac", "enam", "wnam", "weur", "eeur"
}

# --- 可选输出 ---
output "bucket_name" {
  description = "The name of the R2 bucket"
  value       = cloudflare_r2_bucket.main.name
}

# output "bucket_id" {
#  description = "The ID of the R2 bucket (usually the same as name)"
#  value       = cloudflare_r2_bucket.main.id
# }