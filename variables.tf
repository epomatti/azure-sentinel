variable "location" {
  type    = string
  default = "eastus2"
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
