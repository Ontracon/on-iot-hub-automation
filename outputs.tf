#Define the outputs from the deployment


data "azurerm_subscription" "current" {}

output "target_azure_subscription" {
  value = "${data.azurerm_subscription.current.display_name}"
}

output "connection_string_iothub" {
  description = "The connection string to the iothub"
  value       = "${azurerm_iothub_shared_access_policy.iot-sas.primary_connection_string}"
}