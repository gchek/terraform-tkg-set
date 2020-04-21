/*================
REGIONS map:
==================
us-east-1         US East (N. Virginia)
us-east-2	      US East (Ohio)
us-west-1	      US West (N. California)
us-west-2	      US West (Oregon)
ca-central-1	  Canada (Central)

eu-west-1	      EU (Ireland)
eu-central-1	  EU (Frankfurt)
eu-west-2	      EU (London)
eu-west-3         EU (Paris)
eu-north-1        EU (stokholm)

ap-northeast-1	  Asia Pacific (Tokyo)
ap-northeast-2	  Asia Pacific (Seoul)
ap-southeast-1	  Asia Pacific (Singapore)
ap-southeast-2	  Asia Pacific (Sydney)
ap-south-1	      Asia Pacific (Mumbai)
sa-east-1	      South America (São Paulo)
=================*/


variable "access_key"     {}      #in env variables
variable "secret_key"     {}      #in env variables
variable "AWS_account"    {}      #in env variables
variable "vmc_token"      {}      #in env variables
variable "my_org_id"      {}      #in env variables

variable "AWS_region"     {default = "eu-central-1"}

variable "TKG_net_name"   {default = "tkg-network"}
variable "TKG_photon"     {default = "photon-3-v1.17.3_vmware.2"}
variable "TKG_haproxy"    {default = "photon-3-capv-haproxy-v0.6.3_vmware.1"}
variable "TKG_EC2"        {default = "tkg-linux-amd64-v1.0.0_vmware.1"}
variable "TKG_demo"       {default = "VMC-TKG-Demo-Appliance_1.0.0"}
variable "TKG_S3_bucket"  {default = "set-tkg-ova"}


/*================
Subnets IP ranges
=================*/
variable "My_subnets" {
  default = {

    SDDC_Mngt           = "10.10.10.0/23"
    SDDC_def            = "192.168.1.0/24"

    VPC1                = "172.201.0.0/16"
    Subnet10-vpc1       = "172.201.10.0/24"
    Subnet20-vpc1       = "172.201.20.0/24"
    Subnet30-vpc1       = "172.201.30.0/24"
  }
}
/*================
VM AMIs
=================*/


/*===================================================
Amazon Machine Images for Tanzu Kubernetes Grid 1.0.0
=====================================================

ap-northeast-1	ami-07d5076afaf13aa77
ap-northeast-2	ami-0cb22de4c4da68542
ap-south-1	    ami-0acc928b65d161ebd
ap-southeast-1	ami-089a436f0bace9335
ap-southeast-2	ami-083ec7e91a68e9c73
eu-central-1	ami-0d9f883266dee911e
eu-west-1	    ami-0ec61dd68529b73e2
eu-west-2	    ami-0e9216661312a1a35
eu-west-3	    ami-05dfe276355eb8f12
sa-east-1	    ami-0cfe19e780369d05f
us-east-1	    ami-0cdd7837e1fdd81f8
us-east-2	    ami-0f02df79b659875ec
us-west-1	    ami-0ec28d83f96a31158
us-west-2	    ami-074a82cfc610da035

=====================================================*/
//variable "VM_AMI"       { default = "ami-0d6621c01e8c2de2c"} # Amazon Linux 2 AMI (HVM), SSD Volume Type - Oregon


//variable "TKG_AMI"      { default = "ami-074a82cfc610da035"} # in us-west-2 - Oregon
variable "TKG_AMI" {
  default = {
    us-west-2           = "ami-074a82cfc610da035"
    eu-central-1        = "ami-0d9f883266dee911e"
    eu-west-2           = "ami-0e9216661312a1a35"
  }
}
variable "key_pair" {
  default = {
    us-west-2           = "my-oregon-key"
    eu-central-1        = "my-frankfurt-key"
  }
}
