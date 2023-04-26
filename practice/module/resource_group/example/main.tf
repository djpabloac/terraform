locals {
  name   = "rg"
  environment = "example"
  location    = "eastus"
}

module "resource_group" {
  source = "../"

  instance_count = 0
  resource_group_name = local.name
  resource_group_location = local.location
  environment = local.environment
}