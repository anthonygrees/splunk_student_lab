# Splunk Student Lab
   
### About  
This repo creates Splunk Enterprise student lab environments on AWS.  
  
  
### What you need to run the Terraform
You will need the following:  
 - AWS access  
 - A `pem` key in the AWS IAM  - https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html
 - Terraform installed  
 - AWS CLI  
 - A code editor like VS Code  
  
Here is a script to set up you laptop using `Brew` - https://github.com/anthonygrees/laptop_setup
  
### Setup the Terraform
First you need the code !  
  
```bash
git clone https://github.com/anthonygrees/splunk_student_lab

cd splunk_student_lab
```
  
Next, create yourself a `terraform.tfvars` file with the following:  
 - node_counter: Is the number of student VM's you need   
 - splunk_password: Is the password to set on Splunk `admin` account  
  
Here is an example `tfvars` file:  
```bash
aws_profile = "default"
aws_key_pair_file = "/Users/yourName/.ssh/yourPEMfile.pem"
aws_key_pair_name = "yourPEMfile"
aws_availability_zone = "a"
tag_customer = "testing"
tag_project = "project"
tag_name = "name"
tag_dept = "department"
tag_contact = "yourName@splunk.com"
tag_application = "splunk_student"
tag_ttl = "4"
node_counter = "1"
splunk_password = "SetApassword55"
linux_node_instance_type = "t3.large"
```
  
### Initiate your Terraform
Execute the terraform. First run the initialise to ensure the plugins you need are installed:  
  
```bash
terraform init
```
  
Before you run Terraform to create your infrastructure, it's a good idea to see what resources it would create. It also helps you verify that Terraform can connect to your AWS account.  
  
```bash
terraform plan
```
  
### Run your Terraform
  
Now run the apply to create the infrastructure.  
  
```bash
terraform apply -auto-approve
```
  
### Apply Complete !
Once the run is complete you will get a list of the `splunk_server_ip` addresses.  
  
```bash
Apply complete! Resources: 9 added, 0 changed, 0 destroyed.

Outputs:

image_id = ami-091127048df1f044d
route_internet_access_id = rtb-0c8293a365ad2c956
security_group_splunk_id = sg-0a81b14c168fc98fb
security_group_ssh_id = sg-0d6d8b4effe83c007
splunk_server_id = [
  [
    "i-077bc45345e48aca7",
    "i-08f792a8324121942",
  ],
]
splunk_server_public_ip = [
  [
    "52.33.117.188",
    "54.148.76.388",
  ],
]
subnet_private_id = subnet-0132085bfe976b75f
subnet_public_id = subnet-0aefe221eb5ffaf77
vpc_id = vpc-081791ad1bf742a05
```
  
### Access Splunk
You can access Splunk Enterprise using the `splunk_server_public_ip` like this:
  
http://<splunk_server_public_ip>:8000  
  
  
### Data Load
Files can be loaded from the `data` directory.  The data is loaded into the `main` index by default and with a `sourcetype` set during the load.  Data is loaded using the `splunk add oneshot` command.  
  
```bash
splunk add oneshot /tmp/data_file.csv -index main -sourcetype test_source -auth user:password
```
  