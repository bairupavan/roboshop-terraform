data "aws_ami" "centos" {
  most_recent = true
  name_regex  = "Centos-8-DevOps-Practice"
  owners      = ["973714476881"]
}

data "aws_security_group" "sg" {
  name = "allow-all"
}

variable "components" {
  default = {
    frontend = {
      name          = "frontend"
      instance_type = "t2.micro"
    }
    mongodb = {
      name          = "mongodb"
      instance_type = "t2.micro"
    }
  }
}

resource "aws_instance" "instance" {
  for_each = var.components
  ami                    = data.aws_ami.centos.image_id
  instance_type          = each.value["instance_type"]
  vpc_security_group_ids = [data.aws_security_group.sg.id]

  tags = {
    Name = each.value["name"]
  }
}

resource "aws_route53_record" "dns" {
  for_each = var.components
  zone_id = "Z08846229MEF59DJAKAS"
  name    = "${each.value["name"]}-dev.pavanbairu.tech"
  type    = "A"
  ttl     = 300
  records = [aws_instance.instance[each.value["name"]].public_ip]
}

