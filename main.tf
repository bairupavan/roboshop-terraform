module "dabase_servers" {
  for_each = var.database_servers
  source = "./module"
  env = var.env
  component_name = each.value["name"]
  instance_type = each.value["instance_type"]
  password = lookup(each.value, "password", "null")
  provisioner = true
}

module "app_servers" {
  depends_on = [module.dabase_servers]
  for_each = var.app_servers
  source = "./module"
  env = var.env
  component_name = each.value["name"]
  instance_type = each.value["instance_type"]
  password = lookup(each.value, "password", "null")
}