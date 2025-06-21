variable "subscription_id" {
  type = string
}

variable "location" {
  type    = string
  default = "eastus2"
}

variable "workload" {
  type = string
}

variable "threat_intelligence_indicator_pattern" {
  type = string
}

variable "threat_intelligence_indicator_validate_from_utc" {
  type = string
}

variable "vm_windows_size" {
  type = string
}

variable "create_vm_windows" {
  type = bool
}

variable "create_waf" {
  type = bool
}

variable "kubernetes_vm_size" {
  type = string
}
