locals {
  name   = "rg"
  environment = "dev"
  location    = "eastus"
}

module "resource_group" {
  source = "./module/resource_group"

  instance_count = 0
  resource_group_name = local.name
  resource_group_location = local.location
  environment = local.environment
}