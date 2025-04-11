# ~/iN/infra/variables.tf - 已取消注释相关变量

variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare API Token"
  sensitive   = true
}

variable "cloudflare_account_id" {
  type        = string
  description = "Cloudflare Account ID"
}

# --- GitLab Pages 项目需要的变量 ---
variable "gitlab_project_id" {
  type        = string
  description = "GitLab Project ID (the numeric ID)"
}

variable "gitlab_project_name" {
  type        = string
  description = "GitLab Project Name"
}

variable "gitlab_owner" {
  type        = string
  description = "GitLab username or group owning the repository for Pages"
}

variable "pages_production_branch" {
  type        = string
  description = "Production branch name for Pages deployment"
  default     = "main"
}

# --- Logpush Job 需要的变量 (保持注释或删除) ---
# variable "axiom_destination_conf" { ... }

# --- Vectorize Index 需要的变量 ---
variable "vectorize_preset" {
  type        = string
  description = "Vectorize index preset name"
  default     = "@cf/baai/bge-small-en-v1.5"
}

# --- (可选) 其他可能需要传递给子模块的变量 ---
# variable "do_class_name" { ... }