variable "service_accounts" {
  type = map(object({
    account_id    = string
    display_name  = string
    description   = string
    project       = string
    project_roles = list(string)
  }))
}

