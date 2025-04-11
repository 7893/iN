# ~/iN/infra/main.tf

# --- 只保留 workers 和 logpush 模块 ---
module "workers" {
  source = "./workers"

  cloudflare_account_id = var.cloudflare_account_id
  # 如果 workers 模块需要其他变量, 在这里传递
}


# --- 暂时注释掉其他所有模块的调用 ---
# module "d1_database" {
#   source = "./d1"
#   # ...
# }
#
# module "r2_bucket" {
#   source = "./r2"
#   # ...
# }
#
# module "vectorize_index" {
#   source = "./vectorize"
#   # ...
# }
#
# module "queues" {
#   source = "./queues"
#   # ...
# }
#
# module "pages_project" {
#   source = "./pages"
#   # ...
# }