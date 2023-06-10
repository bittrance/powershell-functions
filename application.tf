resource "azurerm_key_vault" "kv" {
  name                = "bittrancepwshexample"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id

}

resource "azurerm_key_vault_access_policy" "self_write" {
  key_vault_id       = azurerm_key_vault.kv.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = data.azurerm_client_config.current.object_id
  secret_permissions = ["Get", "Set", "Delete", "Purge"]
}

resource "random_string" "aad_secret" {
  length  = 40
  special = true
}

resource "random_uuid" "scope" {}

resource "azurerm_key_vault_secret" "aad_secret" {
  name         = "AAD-CLIENT-SECRET"
  value        = random_string.aad_secret.result
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_key_vault_access_policy.self_write]
}

resource "azuread_application" "aad_app" {
  display_name = "powershell-example"

  api {
    requested_access_token_version = 2

    oauth2_permission_scope {
      admin_consent_description  = "."
      admin_consent_display_name = "Use AzFunc powershell-example"
      enabled                    = true
      id                         = random_uuid.scope.result
      type                       = "User"
      user_consent_description   = "."
      user_consent_display_name  = "Use AzFunc powershell-example"
      value                      = "use"
    }
  }
}

resource "azuread_application_pre_authorized" "azcli" {
  application_object_id = azuread_application.aad_app.object_id
  authorized_app_id     = "04b07795-8ddb-461a-bbee-02f9e1bf7b46"
  permission_ids        = [random_uuid.scope.result]
}