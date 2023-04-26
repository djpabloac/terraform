data "azurerm_resource_group" "rg" {
  # name = var.resource_group_name == "minuevorgdev" ? "minuevorg1" : "minuevorgdev2"
  name = var.resource_group_name
}

# data "azurerm_resource_group" "rg-dev" {
#   name = var.resource_group_secondary_name
# }
