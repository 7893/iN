# ~/iN/infra/r2/variables.tf

variable "cloudflare_account_id" {
  type        = string
  description = "Cloudflare Account ID (passed from root module)"
}

variable "bucket_name" {
  type        = string
  description = "Name for the R2 bucket"
}