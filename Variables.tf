variable "location" {
    default = "East Us"
}

variable "vm_size" {
    default = "Standard_B2s"
}

variable "admin_username" {
    default = "azureuser"
}

variable "admin_password" {
    sensitive = true
}
variable "azure_resource_group" {
    default = "tf.web.app"
}