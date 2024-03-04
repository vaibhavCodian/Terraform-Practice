# Creates the service accounts; iterate over each element in the service_accounts variable.

resource "google_service_account" "service_account" {
  for_each = var.service_accounts
  
  account_id   = each.value.account_id
  display_name = each.value.display_name
  description  = each.value.description
  project      = each.value.project
}

# locals block: defines a local value iam_members that is used to create a list of all the roles that need to be assigned to each service account.
locals {
  iam_members = flatten([
    for sa, details in var.service_accounts : [
      for role in details.project_roles : {
        key     = "${sa}.${role}"
        project = details.project
        role    = role
        member  = "serviceAccount:${google_service_account.service_account[sa].email}"
      }
    ]
  ])
}

resource "google_project_iam_member" "project_iam_member" {
  for_each = { for iam in local.iam_members : iam.key => iam }

  project = each.value.project
  role    = each.value.role
  member  = each.value.member
}
