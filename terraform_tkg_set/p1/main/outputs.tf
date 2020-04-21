/*================
Outputs from Various Module
=================*/

output "proxy_url"              {value = module.SDDC.proxy_url}
output "vc_url"                 {value = module.SDDC.vc_url}
output "GOVC_vc_url"            {value = module.SDDC.GOVC_vc_url}
output "SDDC_mgmt"              {value = module.SDDC.SDDC_mgmt}
output "cloud_username"         {value = module.SDDC.cloud_username}
output "cloud_password"         {
  sensitive = true
  value = module.SDDC.cloud_password
}
output "TKG_IP"                 {value = module.EC2s.TKG_IP}
output "TKG_DNS"                {value = module.EC2s.TKG_DNS}
output "TKG_net_name"           {value = var.TKG_net_name}
output "TKG_photon"             {value = var.TKG_photon}
output "TKG_haproxy"            {value = var.TKG_haproxy}
output "TKG_EC2"                {value = var.TKG_EC2}
output "TKG_S3_bucket"          {value = var.TKG_S3_bucket}
output "key_pair"               {value = var.key_pair[var.AWS_region]}





