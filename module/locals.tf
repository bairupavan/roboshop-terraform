locals {
  name = var.env != "" ? "${var.component_name}-${var.env}" : var.component_name
  db = [
    "rm -rf roboshop-shell-script",
    "git clone https://github.com/pavanbairu/roboshop-shell-script.git ",
    "cd roboshop-shell-script",
    "sudo bash ${var.component_name}.sh ${var.password}"
  ]
  app = [
    "echo ok",
    "sudo labauto ansible",
    "ansible-pull -i localhost, -U https://github.com/bairupavan/roboshop-ansible roboshop.yml -e env=${var.env} -erole_name=${var.component_name}"
  ]

  app_tags = {
    Name = "${var.component_name}-${var.env}"
    Monitor = "true"    # monitoring app servers on prometheus server
  }

  db_tags = {
    Name = "${var.component_name}-${var.env}"
    env = var.env                                    #created more tag names in prometheus UI to identify the  app servers
    component = var.component_name
  }
}