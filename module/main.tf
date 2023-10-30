# creating ec2 instance
resource "aws_instance" "instance" {
  ami                    = data.aws_ami.centos.image_id # fetching ami_id using data block
  instance_type          = var.instance_type
  vpc_security_group_ids = [data.aws_security_group.sg.id]                #fetching security group id using data block
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name # attaching instance profile to each instance

  tags = {
    Name = local.name
  }
}

resource "null_resource" "provisioner" {
  depends_on = [aws_instance.instance, aws_route53_record.dns] # will execute only after successful creation of instance and route53

  # triggers are used to run the resource when made any modifications
  triggers = {
    private_ip = aws_instance.instance.private_ip
  }
  # connecting to the server using below credentials
  connection {
    type     = "ssh"
    user     = "centos"
    password = "DevOps321"
    host     = aws_instance.instance.private_ip
  }

  provisioner "remote-exec" {
    inline = var.app_type == "db" ? local.db : local.app # checking if app_type is db then executes db else app
  }
}

# creating the IAM role to provide accesses to instance
resource "aws_iam_role" "role" {
  name = "${var.component_name}-${var.env}-role" # role name for each instance

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "${var.component_name}-${var.env}-role"
  }
}

# creating the instance profile to attach to each instance
resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.component_name}-${var.env}-instance-profile"
  role = aws_iam_role.role.name # attaching role to instance profile
}

# creating aws_iam_role_policy to access the aws ssm parameter store
resource "aws_iam_role_policy" "iam_role_policy" {
  name = "${var.component_name}-${var.env}-ssm-paramter-store-policy"
  role = aws_iam_role.role.id # attaching this policy to the role

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "ssm:*",
#          "ssm:GetParameterHistory",# 4 permissions are given
#          "ssm:GetParametersByPath",
#          "ssm:GetParameters",
#          "ssm:GetParameter"
        ],
        "Resource" : "arn:aws:ssm:us-east-1:416622536569:parameter/${var.env}.${var.component_name}.*"
        # access to all the ARN path starts with env and component name
      },
      {
        "Sid" : "VisualEditor1",
        "Effect" : "Allow",
        "Action" : "ssm:DescribeParameters",
        "Resource" : "*"
      }
    ]
  })
}

# creating route for all the instance ips
resource "aws_route53_record" "dns" {
  zone_id = "Z08846229MEF59DJAKAS"                      # zoned_id will get route53 -> host zones
  name    = "${var.component_name}-dev.pavanbairu.tech" # dns for ip
  type    = "A"
  ttl     = 300
  records = [aws_instance.instance.private_ip] # ip
}
