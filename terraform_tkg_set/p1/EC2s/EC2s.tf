

variable "key_pair"             {}
variable "TKG-AMI"              {}

variable "Subnet10-vpc1"        {}
variable "Subnet10-vpc1-base"   {}
variable "GC-SG-VPC1"           {}
variable "AWS_region"           {}


/*================
EC2 Instances
=================*/

resource "aws_network_interface" "TKG-Eth0" {
  subnet_id                     = var.Subnet10-vpc1
  security_groups               = [var.GC-SG-VPC1]
  private_ips                   = [cidrhost(var.Subnet10-vpc1-base, 200)]
}
resource "aws_instance" "TKG" {
  ami                           = var.TKG-AMI[var.AWS_region]
  instance_type                 = "t2.medium"
  root_block_device {
    volume_type = "gp2"
    volume_size = 20
    delete_on_termination       = true
  }
  network_interface {
    network_interface_id        = aws_network_interface.TKG-Eth0.id
    device_index                = 0
  }
  key_name                      = var.key_pair[var.AWS_region]
  user_data                     = file("${path.module}/user-data.ini")

  tags = {
    Name = "GC-TKG-vpc1"
  }
}


/*================
Outputs variables for other modules to use
=================*/

output "TKG_IP"           {value = aws_instance.TKG.public_ip}
output "TKG_DNS"          {value = aws_instance.TKG.public_dns}
