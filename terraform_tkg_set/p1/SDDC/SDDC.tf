variable "my_org_id" {}          
variable "SDDC_Mngt" {}           
variable "SDDC_def" {}
variable "customer_subnet_id" {}
variable "region" {}
variable "AWS_account" {}



data "vmc_org" "my_org" {
}

data "vmc_connected_accounts" "my_accounts" {
  account_number = var.AWS_account
}

data "vmc_customer_subnets" "my_subnets" {
  connected_account_id = data.vmc_connected_accounts.my_accounts.id
  region               = replace(upper(var.region), "-", "_")
}

resource "vmc_sddc" "Terraform_SDDC1" {
    sddc_name           = "Terraform_TKG_SDDC"
    vpc_cidr            = var.SDDC_Mngt
    num_host            = 1
    provider_type       = "AWS"
    region              = data.vmc_customer_subnets.my_subnets.region
    vxlan_subnet        = var.SDDC_def
    delay_account_link  = false
    skip_creating_vxlan = false
    host_instance_type  = "I3_METAL"
    sso_domain          = "vmc.local"
    deployment_type     = "SingleAZ"
    sddc_type           = "1NODE"
    account_link_sddc_config {
        customer_subnet_ids  = [var.customer_subnet_id]
        connected_account_id = data.vmc_connected_accounts.my_accounts.id
    }
    timeouts {
        create = "300m"
        update = "300m"
        delete = "180m"
    }
}



/*==============
Outputs
===============*/

output "proxy_url"          {value = trimsuffix(trimprefix(vmc_sddc.Terraform_SDDC1.nsxt_reverse_proxy_url, "https://"), "/sks-nsxt-manager")}
output "vc_url"             {value = trimsuffix(trimprefix(vmc_sddc.Terraform_SDDC1.vc_url, "https://"), "/")}
output "cloud_username"     {value = vmc_sddc.Terraform_SDDC1.cloud_username}
output "cloud_password"     {value = vmc_sddc.Terraform_SDDC1.cloud_password}
output "GOVC_vc_url"        {value = format("%s%s",vmc_sddc.Terraform_SDDC1.vc_url,"sdk")}
output "SDDC_mgmt"          {value = vmc_sddc.Terraform_SDDC1.vpc_cidr}

