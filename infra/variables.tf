# ~/iN/infra/variables.tf

variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare API Token"
  sensitive   = true
}

variable "cloudflare_account_id" {
  type        = string
  description = "Cloudflare Account ID"
}



# --- 其他暂时不需要的变量可以注释掉 ---
# variable "gitlab_project_id" { ... }
# variable "gitlab_project_name" { ... }
# variable "gitlab_owner" { ... }
# variable "pages_production_branch" { ... }
# variable "vectorize_preset" { ... }
# variable "do_class_name" { ... }