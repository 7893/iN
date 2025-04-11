# ~/iN/infra/workers/variables.tf

variable "cloudflare_account_id" {
  type        = string
  description = "Cloudflare Account ID (passed from root module)"
}

# --- 可选输入变量 ---
# variable "worker_scripts" {
#   type = map(object({
#     content = optional(string)
#     path    = optional(string)
#   }))
#   description = "Map of worker names to their content or script file path"
#   default = {}
# }
#
# variable "do_class_name" {
#   type = string
#   description = "Durable Object class name for binding"
#   default = "TaskCoordinator"
# }
#
# variable "queue_bindings" {
#   type = map(string) # Map of binding name to queue name/id
#   default = {}
# }
#
# variable "r2_bucket_bindings" {
#   type = map(string) # Map of binding name to bucket name
#   default = {}
# }
#
# variable "d1_database_bindings" {
#  type = map(string) # Map of binding name to database id
#  default = {}
# }
#
# variable "vectorize_bindings" {
#   type = map(string) # Map of binding name to index name
#   default = {}
# }