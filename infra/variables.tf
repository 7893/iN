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

# --- GitLab Pages 项目需要的变量 ---
variable "gitlab_project_id" {
  type        = string
  description = "GitLab Project ID (the numeric ID)"
}

variable "gitlab_project_name" {
  type        = string
  description = "GitLab Project Name (should match repo name in URL)"
  default     = "in"
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