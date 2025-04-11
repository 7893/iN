# ~/iN/infra/pages/variables.tf

variable "cloudflare_account_id" {
  type        = string
  description = "Cloudflare Account ID (passed from root module)"
}

variable "project_name" {
  type        = string
  description = "Name for the Cloudflare Pages project"
}

variable "production_branch" {
  type        = string
  description = "Production branch name"
}

# --- 接收 GitLab 相关变量 ---
variable "gitlab_project_id" {
  type        = string
  description = "GitLab Project ID"
}

variable "gitlab_project_name" {
  type        = string
  description = "GitLab Project Name"
}

variable "gitlab_owner" {
  type        = string
  description = "GitLab Owner (username or group)"
}