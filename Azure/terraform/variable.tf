variable "names" {
  description = "names to be used"
  type        = list(string)
  default     = ["master", "worker", "NFS"]
}

variable "linux_vm_image_publisher" {
  type        = string
  description = "Virtual machine source image publisher"
  default     = "OpenLogic"
}

variable "linux_vm_image_offer" {
  type        = string
  description = "Virtual machine source image offer"
  default     = "CentOS"
}

variable "centos_8_sku" {
  type        = string
  description = "SKU for latest CentOS 8 "
  default     = "8_5"
}