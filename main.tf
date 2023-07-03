terraform {
  required_providers {
    azuread = {
      source = "hashicorp/azuread"
      version = "2.39.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.57.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

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

  identity {
    type = "SystemAssigned"
  }

  auth_settings_v2 {
    auth_enabled           = true
    require_authentication = true
    unauthenticated_action = "Return401"

    login {}

    active_directory_v2 {
      client_id                  = azuread_application.aad_app.application_id
      client_secret_setting_name = "AAD_CLIENT_SECRET"
      tenant_auth_endpoint       = "https://sts.windows.net/${data.azurerm_client_config.current.tenant_id}/v2.0"
    }
  }

  app_settings = {
    "FUNCTIONS_EXTENSION_VERSION" = "~4",
    "FUNCTIONS_WORKER_RUNTIME"    = "powershell",
    "AAD_CLIENT_SECRET"           = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=AAD-CLIENT-SECRET)"
  }

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
      tags,
    ]
  }

  depends_on = [azurerm_key_vault_secret.aad_secret]
  tags       = {}
}

resource "azurerm_key_vault_access_policy" "kv_policy" {
  key_vault_id       = azurerm_key_vault.kv.id
  tenant_id          = azurerm_windows_function_app.function_app.identity[0].tenant_id
  object_id          = azurerm_windows_function_app.function_app.identity[0].principal_id
  secret_permissions = ["Get"]
}
