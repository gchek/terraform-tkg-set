

variable "TKG_net"        {}
variable "TKG_net_gw"     {}
variable "TKG_net_dhcp"   {}
variable "TKG_net_name"   {}

variable "SDDC_mgmt"      {}



data "nsxt_policy_tier0_gateway" "vmc" {
  display_name = "vmc"
}

data "nsxt_policy_transport_zone" "TZ" {
  display_name = "vmc-overlay-tz"
}
/*======================================
Need to import the existing infra.
1 - delete default rules (we will recreate them below)
2 - use
    terraform import module.NSX.nsxt_policy_gateway_policy.mgw mgw/default
and
    terraform import module.NSX.nsxt_policy_gateway_policy.cgw cgw/default


Scope for MGW is "/infra/labels/mgw"
Scope for CGW (applied to:) are:
  INTERNET: "/infra/labels/cgw-public"
  DX:       "/infra/labels/cgw-direct-connect"  
  VPN:      "/infra/labels/cgw-vpn"  
  VPC:      "/infra/labels/cgw-cross-vpc"  
  ALL:      "/infra/labels/cgw-all"  


T0 groups
---------
Connected VPC:    "/infra/tier-0s/vmc/groups/connected_vpc",
S3 Prefixes:      "/infra/tier-0s/vmc/groups/s3_prefixes",
Direct Connect:   "/infra/tier-0s/vmc/groups/directConnect_prefixes"

========================================*/

/*========
MGW rules
=========*/
resource "nsxt_policy_gateway_policy" "mgw" {
  category                = "LocalGatewayRules"
  description             = "Terraform provisioned Gateway Policy"
  display_name            = "default"
  domain                  = "mgw"
  # New rules below . . 
  # Order in code below is order in GUI

  /* TKG net to vCenter */
  rule {
    action = "ALLOW"
    destination_groups    = ["/infra/domains/mgw/groups/VCENTER"]
    destinations_excluded = false
    direction             = "IN_OUT"
    disabled              = false
    display_name          = "TKG network to vCenter"
    ip_version            = "IPV4_IPV6"
    logged                = false
    profiles              = []
    scope                 = ["/infra/labels/mgw"]
    services              = ["/infra/services/HTTPS"]
    source_groups         = [nsxt_policy_group.MGW_TKG_net.path]
    sources_excluded = false
  }
  /* ESXi Provisioning Rules */
  rule {
    action = "ALLOW"
    destination_groups    = ["/infra/domains/mgw/groups/ESXI"]
    destinations_excluded = false
    direction             = "IN_OUT"
    disabled              = false
    display_name          = "ESXi Provisioning"
    ip_version            = "IPV4_IPV6"
    logged                = false
    profiles              = []
    scope                 = ["/infra/labels/mgw"]
    services = [
      "/infra/services/HTTPS",
      "/infra/services/ICMP-ALL",
      "/infra/services/VMware_Remote_Console"

    ]
    source_groups         = []
    sources_excluded = false
  }

  /* vCenter Inbound */
  rule {
    action = "ALLOW"
    destination_groups    = ["/infra/domains/mgw/groups/VCENTER"]
    destinations_excluded = false
    direction             = "IN_OUT"
    disabled              = false
    display_name          = "vCenter Inbound"
    ip_version            = "IPV4_IPV6"
    logged                = false
    profiles              = []
    scope                 = ["/infra/labels/mgw"]
    services = [
      "/infra/services/HTTPS",
      "/infra/services/ICMP-ALL",
      "/infra/services/SSO"
    ]
    source_groups    = []
    sources_excluded = false
  }

//  # Default rules - need to be added here otherwise they will be removed on first terraform apply
  rule {
    action = "ALLOW"
    destination_groups    = []
    destinations_excluded = false
    direction             = "IN_OUT"
    disabled              = false
    display_name          = "ESXi Outbound"
    ip_version            = "IPV4_IPV6"
    logged                = false
    profiles              = []
    scope                 = ["/infra/labels/mgw"]
    services = []
    source_groups         = ["/infra/domains/mgw/groups/ESXI"]
    sources_excluded = false
  }
  rule {
    action = "ALLOW"
    destination_groups    = []
    destinations_excluded = false
    direction             = "IN_OUT"
    disabled              = false
    display_name          = "vCenter Outbound"
    ip_version            = "IPV4_IPV6"
    logged                = false
    profiles              = []
    scope                 = ["/infra/labels/mgw"]
    services = []
    source_groups         = ["/infra/domains/mgw/groups/VCENTER"]
    sources_excluded = false
  }
}

/*========
CGW rules
=========*/

resource "nsxt_policy_gateway_policy" "cgw" {
  category              = "LocalGatewayRules"
  description           = "Terraform provisioned Gateway Policy"
  display_name          = "default"
  domain                = "cgw"
  # New rules below . . 
  # Order in code below is order in GUI
//
  rule {
    action = "ALLOW"
    destination_groups    = []
    destinations_excluded = false
    direction             = "IN_OUT"
    disabled              = false
    display_name          = "TKG net to internet"
    ip_version            = "IPV4_IPV6"
    logged                = false
    profiles              = []
    scope                 = ["/infra/labels/cgw-public"]
    services              = []
    source_groups         = [nsxt_policy_group.TKG_net.path]
    sources_excluded      = false
  }
  rule {
    action = "ALLOW"
    destination_groups    = [nsxt_policy_group.SDDC_mgmt.path]
    destinations_excluded = false
    direction             = "IN_OUT"
    disabled              = false
    display_name          = "TKG net to SDDC mgmt"
    ip_version            = "IPV4_IPV6"
    logged                = false
    profiles              = []
    scope                 = ["/infra/labels/cgw-public"]
    services              = []
    source_groups         = [nsxt_policy_group.TKG_net.path]
    sources_excluded      = false
  }
  rule {
    action = "ALLOW"
    destination_groups    = [
      "/infra/tier-0s/vmc/groups/connected_vpc",
      "/infra/tier-0s/vmc/groups/s3_prefixes"
    ]
    destinations_excluded = false
    direction             = "IN_OUT"
    disabled              = false
    display_name          = "VMC to AWS"
    ip_version            = "IPV4_IPV6"
    logged                = false
    profiles              = []
    scope                 = ["/infra/labels/cgw-cross-vpc"]
    services              = []
    source_groups         = []
    sources_excluded      = false
  }
  rule {
    action = "ALLOW"
    destination_groups    = []
    destinations_excluded = false
    direction             = "IN_OUT"
    disabled              = false
    display_name          = "AWS to VMC"
    ip_version            = "IPV4_IPV6"
    logged                = false
    profiles              = []
    scope                 = ["/infra/labels/cgw-cross-vpc"]
    services = []
    source_groups    = [
      "/infra/tier-0s/vmc/groups/connected_vpc",
      "/infra/tier-0s/vmc/groups/s3_prefixes"
    ]
    sources_excluded = false
  }

  //  # Default rules - need to be added here otherwise they will be removed on first terraform apply
  rule {
    action = "DROP"
    destination_groups    = []
    destinations_excluded = false
    direction             = "IN_OUT"
    disabled              = false
    display_name          = "Default VTI Rule"
    ip_version            = "IPV4_IPV6"
    logged                = false
    profiles              = []
    scope                 = ["/infra/labels/cgw-vpn"]
    services = []
    source_groups         = []
    sources_excluded = false
  }
}


/*==============
Create segments
===============*/

resource "nsxt_policy_segment" "tkg-network" {
  display_name        = var.TKG_net_name
  description         = "Terraform provisioned Segment"
  connectivity_path   = "/infra/tier-1s/cgw"
  transport_zone_path = data.nsxt_policy_transport_zone.TZ.path
  subnet {
    cidr              = var.TKG_net_gw
    dhcp_ranges       = [var.TKG_net_dhcp]
  }
}


/*===================
Create Network Groups
====================*/

resource "nsxt_policy_group" "SDDC_mgmt" {
  display_name = "SDDC Management"
  description  = "Terraform provisioned Group"
  domain       = "cgw"
  criteria {
    ipaddress_expression {
      ip_addresses = [var.SDDC_mgmt]
    }
  }
}
resource "nsxt_policy_group" "TKG_net" {
  display_name = "TKG Network"
  description  = "Terraform provisioned Group"
  domain       = "cgw"
  criteria {
    ipaddress_expression {
      ip_addresses = [var.TKG_net]
    }
  }
}
/*======================
Create Management Groups
=======================*/

resource "nsxt_policy_group" "MGW_TKG_net" {
  display_name = "TKG Network"
  description  = "Terraform provisioned Group"
  domain       = "mgw"
  criteria {
    ipaddress_expression {
      ip_addresses = [var.TKG_net]
    }
  }
}







