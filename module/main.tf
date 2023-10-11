resource "aws_instance" "instance" {
  ami                    = data.aws_ami.centos.image_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [data.aws_security_group.sg.id]

  tags = {
    Name = var.component_name
  }
}

resource "null_resource" "provisioner" {
  depends_on = [aws_instance.instance, aws_route53_record.dns]

  connection {
    type     = "ssh"
    user     = "centos"
    password = "DevOps321"
    host     = aws_instance.instance[var.component_name].private_ip
  }

  provisioner "remote-exec" {
    inline = [
      "rm -rf roboshop-shell-script",
      "git clone https://github.com/pavanbairu/roboshop-shell-script.git ",
      "cd roboshop-shell-script",
      "sudo bash ${var.component_name}.sh ${var.password}"
    ]
  }
}
resource "aws_route53_record" "dns" {
  zone_id = "Z08846229MEF59DJAKAS"
  name    = "${var.component_name}-dev.pavanbairu.tech"
  type    = "A"
  ttl     = 300
  records = [aws_instance.instance[var.component_name].private_ip]
}
