provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "powershell-example"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "logs" {
  name                = "powershell-example"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags = {}
}

resource "azurerm_storage_account" "storage_account" {
  name                     = "bittrancepwshexample"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = {}
}

resource "azurerm_application_insights" "function_insights" {
  name                = "powershell-example"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  workspace_id        = azurerm_log_analytics_workspace.logs.id
  application_type    = "Node.JS"
  tags = {}
}

resource "azurerm_service_plan" "service_plan" {
  name                = "powershell-example"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Windows"
  sku_name            = "Y1"
  tags = {}
  }

resource "azurerm_windows_function_app" "function_app" {
  name                       = "powershell-example"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  storage_account_name       = azurerm_storage_account.storage_account.name
  storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key
  service_plan_id            = azurerm_service_plan.service_plan.id
  site_config {
    application_insights_key = azurerm_application_insights.function_insights.instrumentation_key
    application_stack {
      powershell_core_version = "7.2"
    }
  }
  app_settings = {
    "FUNCTIONS_EXTENSION_VERSION"    = "~4",
    "FUNCTIONS_WORKER_RUNTIME"       = "powershell",
  }
  tags = {}
  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
      tags,
    ]
  }
}
