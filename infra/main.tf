# ~/iN/infra/main.tf - 暂时跳过 Vectorize

# 调用 Workers 子模块
module "workers" {
  source = "./workers"
  cloudflare_account_id = var.cloudflare_account_id
  # ... 其他 workers 需要的变量 ...
}

# 调用 D1 子模块
module "d1_database" {
  source = "./d1"
  cloudflare_account_id = var.cloudflare_account_id
  database_name         = "in-d1-a-database-20250402"
}

# 调用 R2 子模块
module "r2_bucket" {
  source = "./r2"
  cloudflare_account_id = var.cloudflare_account_id
  bucket_name           = "in-r2-a-bucket-20250402"
}

# --- 暂时注释掉 vectorize 子模块的调用 ---
# module "vectorize_index" {
#   source = "./vectorize"
#
#   cloudflare_account_id = var.cloudflare_account_id
#   index_name            = "in-vectorize-a-index-20250402"
#   vectorize_preset      = var.vectorize_preset
# }
# ---------------------------------------

# --- 确保调试时添加的 vectorize 资源也已移除或注释掉 ---
# resource "cloudflare_vectorize_index" "main_vectorize_index_debug" {
#  ...
# }
# ------------------------------------------------------

# 调用 Queues 子模块
module "queues" {
  source = "./queues"
  cloudflare_account_id = var.cloudflare_account_id
  # 可以在这里传递队列配置, 或在子模块内定义名称
}

# 调用 Pages 子模块
module "pages_project" {
  source = "./pages"
  cloudflare_account_id   = var.cloudflare_account_id
  project_name            = "in-pages"
  production_branch       = var.pages_production_branch
  gitlab_project_id     = var.gitlab_project_id
  gitlab_project_name   = var.gitlab_project_name
  gitlab_owner          = var.gitlab_owner
}

# module "logpush_job" { ... } # 保持注释或删除状态