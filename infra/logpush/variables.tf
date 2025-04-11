# ~/iN/infra/logpush/variables.tf

variable "cloudflare_account_id" {
  type        = string
  description = "Cloudflare Account ID (passed from root module)"
}

variable "job_name" {
  type        = string
  description = "Name for the Logpush job"
}

variable "dataset" {
  type        = string
  description = "The dataset to push (e.g., http_requests, workers_trace_events)"
}

variable "destination_conf" {
  type        = string
  description = "Logpush destination configuration string"
  sensitive   = true
}

# 可选，如果需要基于 Zone 推送
# variable "cloudflare_zone_id" {
#   type = string
#   description = "Cloudflare Zone ID (optional, for zone-level jobs)"
#   default = null
# }