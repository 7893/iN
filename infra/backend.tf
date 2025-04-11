# ~/iN/infra/backend.tf (正确内容)

terraform {
  backend "http" {
    address        = "https://gitlab.com/api/v4/projects/68866224/terraform/state/default"
    lock_address   = "https://gitlab.com/api/v4/projects/68866224/terraform/state/default/lock"
    unlock_address = "https://gitlab.com/api/v4/projects/68866224/terraform/state/default/lock"
    lock_method    = "POST"
    unlock_method  = "DELETE"
    retry_wait_min = 5
    # 注意：这里不需要也不应该包含 username 或 password
  }
}