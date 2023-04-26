locals {
  rg_name = format("%s%s000", var.resource_group_name, var.environment)
}

resource "azurerm_resource_group" "rg" {
  name = "${local.rg_name}1"
  location = var.resource_group_location

  tags = {
    environment = var.environment
  }
}