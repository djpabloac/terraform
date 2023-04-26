variable "resource_group_name" {
    type = string
    description = "Nombre del grupo de recursos"
}

variable "resource_group_secondary_name" {
    type = string
    description = "Nombre secundario del grupo de recursos"
}

# export TF_VAR_resource_group_secondary_name="minuevorgdev"