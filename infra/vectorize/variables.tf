# ~/iN/infra/vectorize/variables.tf

variable "cloudflare_account_id" {
  type        = string
  description = "Cloudflare Account ID (passed from root module)"
}

variable "index_name" {
  type        = string
  description = "Name for the Vectorize index"
}

variable "vectorize_preset" {
  type        = string
  description = "Vectorize index preset name (e.g., @cf/baai/bge-small-en-v1.5)"
}