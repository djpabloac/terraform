locals {
  rg_name = "rgexample"
  rg_location = "eastus"
  environment = "example"
}

module "vm_linux" {
  source = "../"

  resource_group_name = local.rg_name
  resource_group_location = local.rg_location
  asset_name = "my_VM_Linux"
  environment = local.environment
  instance_count = 1
}