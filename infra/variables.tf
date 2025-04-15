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

variable "pages_production_branch" {
  type        = string
  description = "Production branch name for Pages deployment"
  default     = "main"
}

variable "gitlab_owner" {
  type        = string
  description = "GitLab 用户名或组织名"
  default     = "79"
}

variable "gitlab_project_name" {
  type        = string
  description = "GitLab 项目名（仓库名）"
  default     = "in"
}

variable "gitlab_project_id" {
  type        = string
  description = "GitLab 项目的数字 ID（当前未使用，仅预留）"
  default     = "68866224"
}
