# JSONファイルを読み込み
locals {
  iam_members = jsondecode(file("${path.module}/DEV_iam_members.json"))
}

# IAMポリシーをループで設定
resource "google_project_iam_member" "iam_members" {
  for_each = { for idx, member in local.iam_members.members : idx => member }

  project = var.project_id
  role    = each.value.role
  member  = each.value.member

  dynamic "condition" {
    for_each = lookup(each.value, "condition", null) != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}