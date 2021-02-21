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
# Creation
#

# networking

resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name          = "${var.tag_name}-vpc"
    X-Dept        = var.tag_dept
    X-Customer    = var.tag_customer
    X-Project     = var.tag_project
    X-Contact     = var.tag_contact
    X-Application = var.tag_application
    X-TTL         = var.tag_ttl
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name          = "${var.tag_name}-gateway"
    X-Dept        = var.tag_dept
    X-Customer    = var.tag_customer
    X-Project     = var.tag_project
    X-Contact     = var.tag_contact
    X-Application = var.tag_application
    X-TTL         = var.tag_ttl
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.default.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}${var.aws_availability_zone}"
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.default.id
  cidr_block        = "10.0.100.0/24"
  availability_zone = "${var.aws_region}${var.aws_availability_zone}"
}

resource "aws_security_group" "ssh" {
  name        = "learn_splunk_ssh"
  description = "Used in a terraform exercise"
  vpc_id      = aws_vpc.default.id

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "splunk" {
  name        = "learn_splunk"
  description = "Used in a terraform exercise"
  vpc_id      = aws_vpc.default.id

  # Allow inbound HTTP connection from all
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



# instances

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
    content     = templatefile("${path.module}/templates/linux_node_user_data.sh.tpl", { splunk_password = var.splunk_password })
    destination = "/tmp/linux_node_user_data.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "bash /tmp/linux_node_user_data.sh"
    ]
  }

}

