#
# Output
#

# AMI ID

output "image_id" {
  value = data.aws_ami.ubuntu.id
}

# splunk server details

# output "splunk_server_name" {
#   value = [aws_instance.splunk.tags.*.Name]
# }

output "splunk_server_id" {
  value = [aws_instance.splunk.*.id]
}

# output "splunk_server_ami" {
#   value = aws_instance.splunk.ami
# }

# output "splunk_serverinstance_type" {
#   value = aws_instance.splunk.instance_type
# }

output "splunk_server_public_ip" {
  value = [aws_instance.splunk.*.public_ip]
}


# networking details

output "vpc_id" {
  value = aws_vpc.default.id
}

output "subnet_public_id" {
  value = aws_subnet.public.id
}

output "subnet_private_id" {
  value = aws_subnet.private.id
}

output "security_group_splunk_id" {
  value = aws_security_group.splunk.id
}

output "security_group_ssh_id" {
  value = aws_security_group.ssh.id
}

output "route_internet_access_id" {
  value = aws_route.internet_access.route_table_id
}