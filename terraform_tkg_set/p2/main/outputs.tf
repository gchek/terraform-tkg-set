/*================
Outputs from Various Module
=================*/


output "TKG_cidr"             {value = trimsuffix(var.VMC_subnets.TKG_net, "/??")}


