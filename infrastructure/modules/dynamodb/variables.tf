# ==============================================================================
# Mandatory variables

variable "table_name" { description = "The table name of the DynamoDB" }

# ==============================================================================
# Default variables

variable "hash_key" { default = "id" }
variable "autoscaling_enabled" { default = true }
variable "attributes" { default = [{
  name = "id"
  type = "S"
}] }
variable "deletion_protection_enabled" {
  description = "True to protect table from accidental deletion"
  default     = false
}
