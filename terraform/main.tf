#
# Data
#

# This retrieves the latest AMI ID for Ubuntu 16.04.

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

#
# instances
#

resource "aws_instance" "splunk" {
  count                  = var.node_counter
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.linux_node_instance_type
  key_name               = var.aws_key_pair_name
  availability_zone      = "${var.aws_region}${var.aws_availability_zone}"
  vpc_security_group_ids = [aws_security_group.ssh.id, aws_security_group.splunk.id]
  subnet_id              = aws_subnet.public.id

  root_block_device {
    delete_on_termination = true
    volume_size           = 100
    volume_type           = "gp2"
  }

  tags = {
    Name          = "splunk-${count.index}"
    X-Dept        = var.tag_dept
    X-Customer    = var.tag_customer
    X-Project     = var.tag_project
    X-Application = var.tag_application
    X-Contact     = var.tag_contact
    X-TTL         = var.tag_ttl
  }

  connection {
    user        = "ubuntu"
    private_key = file(var.aws_key_pair_file)
    host        = self.public_ip
  }

  provisioner "file" {
    destination = "/tmp/db_audit_30DAY.csv"
    source      = "./data/db_audit_30DAY.csv"
  }

  provisioner "file" {
    destination = "/tmp/indexes.conf"
    source      = "./templates/indexes.conf"
  }

  provisioner "file" {
    destination = "/tmp"
    source      = "./data/cloudtrail"
  }

    provisioner "file" {
    destination = "/tmp"
    source      = "./data/waf"
  }

  provisioner "file" {
    content     = templatefile("${path.module}/templates/linux_node_user_data.sh.tpl", { splunk_password = var.splunk_password, load_awscodecommit = var.load_awscodecommit})
    destination = "/tmp/linux_node_user_data.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "bash /tmp/linux_node_user_data.sh"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo reboot"
    ]
    on_failure = "continue"
  }

}

