output "vnet_id" {
  value = module.app_vnet.vnet_id
}

output "subnet_ids" {
  value = module.app_vnet.vnet_subnets_name_id
}