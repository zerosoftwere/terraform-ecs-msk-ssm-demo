data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "bastion" {
  ami                     = data.aws_ami.ubuntu.id
  instance_type           = "t2.nano"
  subnet_id               = aws_subnet.main_subnet_1.id
  key_name                = aws_key_pair.ssh_key.key_name
  source_dest_check       = false
  disable_api_termination = false
  ebs_optimized           = false
  monitoring              = false
  hibernation             = false

  credit_specification {
    cpu_credits = "standard"
  }

  vpc_security_group_ids = [
    aws_security_group.allow_all_out_sg.id,
    aws_security_group.allow_ssh_sg.id,
    aws_security_group.allow_https_sg.id,
    aws_security_group.database_sg.id,
    aws_security_group.allow_cluster_ports_sg.id
  ]

  tags = {
    Name = "Bastion"
  }
}

output "bastion_ip" {
  value = aws_instance.bastion.public_ip
}

output "bastion_private_ip" {
  value = aws_instance.bastion.private_ip
}