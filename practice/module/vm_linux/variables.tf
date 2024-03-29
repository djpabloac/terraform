variable "resource_group_name" {
  type = string
}

variable "resource_group_location" {
  type = string
}

variable "asset_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "instance_count" {
  type = number
  default = 1
}