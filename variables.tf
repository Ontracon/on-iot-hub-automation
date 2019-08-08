#Define the variables for the deployment

variable "location" {
  type        = "string"
  default     = "westeurope"
  description = "Specify a location see: az account list-locations -o table"
}

variable "resource_group_name" {
  description = "Default resource group name that the application will be created in."
  default     = "on-ams-dev-iot-pr"
}

variable "tags" {
  description = "The tags to associate with the resources."
  type        = "map"

  default = {
    owner   = "p.ridderbusch@ontracon.de"
    env     = "Development"
    project = "solutions.hamburg"
  }
}
