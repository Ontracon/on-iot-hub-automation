# Needs to run with additional Configuration on Init: 
# terraform init -backend-config="access_key=Storage Access Key"
#

# Backend Configuration (Make sure Storage Account & Container does exists
# Skip (comment out) if using local tfstate file

terraform {
  backend "azurerm" {
    storage_account_name = "onamsdevtrainingprst"
    container_name       = "iot-tfstate"
    resource_group_name  = "on-ams-dev-traning-pr"
    key                  = "terraform.tfstate"

  }
}


# Configure the Microsoft Azure Provider.
provider "azurerm" {
  version = "1.27.0"
}


# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
  tags     = "${var.tags}"
}

# Create storage account for message logs
resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "onamsdeviotprst"
    resource_group_name         = "${azurerm_resource_group.rg.name}"
    location                    = "${var.location}"
    account_tier                = "Standard"
    account_kind                = "StorageV2"
    account_replication_type    = "LRS"

    tags = "${var.tags}"
}

#Create blob container to store messages from device(s)
resource "azurerm_storage_container" "message-container" {
  name                  = "d2c-messages"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  storage_account_name  = "${azurerm_storage_account.mystorageaccount.name}"
  container_access_type = "private"
}

resource "azurerm_iothub" "iothub" {
  name                = "ontraconIotHub"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${var.location}"

  sku {
    name     = "S1"
    tier     = "Standard"
    capacity = "1"
  }

  endpoint {
    type                       = "AzureIotHub.StorageContainer"
    connection_string          = "${azurerm_storage_account.mystorageaccount.primary_blob_connection_string}"
    name                       = "message-export-D2C"
    batch_frequency_in_seconds = 60
    max_chunk_size_in_bytes    = 10485760
    container_name             = "${azurerm_storage_container.message-container.name}"
    encoding                   = "Avro"
    file_name_format           = "{iothub}/{partition}_{YYYY}_{MM}_{DD}_{HH}_{mm}"
  }

  route {
    name           = "message-export-D2C"
    source         = "DeviceMessages"
    condition      = "true"
    endpoint_names = ["message-export-D2C"]
    enabled        = true
  }

    tags = "${var.tags}"
}

resource "azurerm_iothub_shared_access_policy" "iot-sas" {
  name                = "PiSimulator"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  iothub_name         = "${azurerm_iothub.iothub.name}"

  registry_read  = true
  registry_write = true
}