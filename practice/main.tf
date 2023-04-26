locals {
  name   = "rg"
  environment = "dev"
  location    = "eastus"
}

module "resource_group" {
  source = "./module/resource_group"

  resource_group_name = local.name
  resource_group_location = local.location
  environment = local.environment
}

module "virtual_machine_linux" {
  source = "./module/vm_linux"

  resource_group_name = module.resource_group.rg_name
  resource_group_location = module.resource_group.rg_location
  environment = local.environment
  asset_name = "my_vm_m"
}