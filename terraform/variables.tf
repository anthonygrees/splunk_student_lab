#
# Variables
#

variable "aws_profile" {
}

///////////////////////////////
// Tags
variable "tag_customer" {
}

variable "tag_project" {
}

variable "tag_name" {
}

variable "tag_dept" {
}

variable "tag_contact" {
}

variable "tag_application" {
}

variable "tag_ttl" {
  default = 4
}

variable "aws_key_pair_file" {
}

variable "aws_key_pair_name" {
}

variable "aws_region" {
  default = "us-west-2"
}

variable "aws_availability_zone" {
  default = "a"
}

variable "linux_node_instance_type" {
  default = "t2.micro"
}

variable "node_counter" {
  default = "1"
}

variable "splunk_password" {
  
}

variable "load_awscodecommit" {
  default = "n"
}

#
# Provider
#

provider "aws" {
  region                  = var.aws_region
  profile                 = var.aws_profile
  shared_credentials_file = "~/.aws/credentials"
}
