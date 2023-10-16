# calling db servers to create ec2, dns and run db servers first
module "dabase_servers" {
  for_each       = var.database_servers # running for all the db servers
  source         = "./module"           # calling the module
  env            = var.env
  component_name = each.value["name"]
  instance_type  = each.value["instance_type"]
  password       = lookup(each.value, "password", "null") # passing null if no password & passing the same password if it has
  provisioner    = true
  app_type       = "db"
}

module "app_servers" {
  depends_on     = [module.dabase_servers] # app servers created only after successful creation of db servers
  for_each       = var.app_servers         # running for all app servers
  source         = "./module"              # calling the module
  env            = var.env
  component_name = each.value["name"]
  instance_type  = each.value["instance_type"]
  password       = lookup(each.value, "password", "null") # passing null if no password & passing the same password if it has
  provisioner    = true
  app_type       = "app"
}