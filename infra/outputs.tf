output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "webapp_name" {
  value = azurerm_linux_web_app.web.name
}

output "webapp_default_hostname" {
  value = azurerm_linux_web_app.web.default_hostname
}

output "acr_name" {
  value = azurerm_container_registry.acr.name
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "webapp_principal_id" {
  value = azurerm_linux_web_app.web.identity[0].principal_id
}
