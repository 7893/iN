# ~/iN/infra/d1/variables.tf

variable "cloudflare_account_id" {
  type        = string
  description = "Cloudflare Account ID (passed from root module)"
}

variable "database_name" {
  type        = string
  description = "Name for the D1 database"
}