# variable "name" {
#   description = "Resource group name"
#   type        = string
# }

# variable "location" {
#   description = "Azure region"
#   type        = string

#   validation {
#     condition = contains([
#       "northcentralus", "northeurope",
#       "westeurope", "uksouth", "ukwest"
#     ], var.location)
#     error_message = "Location must be a valid Azure region."
#   }
# }

# variable "tags" {
#   description = "Resource tags"
#   type        = map(string)
#   default     = {}
# }
