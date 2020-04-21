

terraform {
  backend "local" {
    path = "../../phase2.tfstate"
  }
}
# Import the state from phase 1 and read the outputs
data "terraform_remote_state" "phase1" {
  backend = "local" 
  config = {
    path    = "../../phase1.tfstate"
  }
}

provider "nsxt" {
//  host                  = data.terraform_remote_state.phase1.outputs.proxy_url
  host                  = var.host
  vmc_token             = var.vmc_token
  allow_unverified_ssl  = true
  enforcement_point     = "vmc-enforcementpoint"
}

/*========================
Configure NSXT Networking
=========================*/


module "NSX" {
  source = "../NSX"

  TKG_net               = var.VMC_subnets["TKG_net"]
  TKG_net_gw            = var.VMC_subnets["TKG_net_gw"]
  TKG_net_dhcp          = var.VMC_subnets["TKG_net_dhcp"]
  TKG_net_name          = data.terraform_remote_state.phase1.outputs.TKG_net_name

  SDDC_mgmt             = data.terraform_remote_state.phase1.outputs.SDDC_mgmt
}
