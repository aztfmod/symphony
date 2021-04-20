variable group_object_id {}
variable member_object_id {}

resource "azuread_group_member" "id" {
  group_object_id  = var.group_object_id
  member_object_id = var.member_object_id
}
