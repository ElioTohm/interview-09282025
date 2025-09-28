variable "region" {
  type        = string
  description = "The AWS region to deploy resources in."
}

variable "default_tags" {
  type        = map(string)
  description = "Default tags to apply to all resources."
  default     = {}
}
