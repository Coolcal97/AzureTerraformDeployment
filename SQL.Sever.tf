# SQL Server
resource "azurerm_mssql_server" "sql_server" {
  name                         = "my-sql-server"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password

  # Disable public access
  public_network_access_enabled = false

  azuread_administrator {
    login_username = "AzureAD Admin"
    object_id      = var.azuread_admin_object_id
  }
}

# SQL Database
resource "azurerm_mssql_database" "sql_db" {
  name           = "my-database"
  server_id      = azurerm_mssql_server.sql_server.id
  sku_name       = "S0"
  max_size_gb    = 2

  # Encrypt the database
  transparent_data_encryption_enabled = true
}

# Firewall rule - block all public access
resource "azurerm_mssql_firewall_rule" "block_all" {
  name             = "block-all"
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Only allow your VNet to access the database
resource "azurerm_mssql_virtual_network_rule" "vnet_rule" {
  name      = "vnet-rule"
  server_id = azurerm_mssql_server.sql_server.id
  subnet_id = azurerm_subnet.AzSN.id
}
