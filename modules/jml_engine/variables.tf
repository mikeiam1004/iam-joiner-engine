variable "domain_name" {
  type        = string
  description = "Primary tenant domain for UPN construction"
  default     = "testgenomic.com"
}

variable "json_data_path" {
  type        = string
  description = "Absolute or relative path to the HR data JSON file"
}
