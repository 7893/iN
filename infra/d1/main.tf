# ~/iN/infra/d1/main.tf (或 d1.tf)

resource "cloudflare_d1_database" "main" {
  account_id = var.cloudflare_account_id
  # 使用从根模块传入的小写标识名称
  name       = var.database_name
}

# --- 可选输出 ---
output "database_id" {
  description = "The ID of the D1 database"
  value       = cloudflare_d1_database.main.id
}

output "database_name" {
  description = "The name of the D1 database"
  value       = cloudflare_d1_database.main.name
}