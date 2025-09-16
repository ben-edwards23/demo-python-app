terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.44.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "InfraAsCode-Main-RG"
    storage_account_name = "bedwtfstate"
    container_name       = "tfstate"
    key                  = "demo-python-app.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# ---- Naming conveniences ----
locals {
  rg_name     = var.resource_group_name
  plan_name   = "${var.name_prefix}-plan"
  webapp_name = var.webapp_name != "" ? var.webapp_name : "${var.name_prefix}-web"
  acr_name    = var.acr_name != "" ? var.acr_name : replace("${var.name_prefix}acr", "-", "")
  tags        = var.tags
}

# ---- Resource Group ----
resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.location
  tags     = local.tags
}

# ---- App Service Plan (Linux) ----
resource "azurerm_service_plan" "plan" {
  name                = local.plan_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = var.plan_sku # e.g. "B1", "P1v3"
  tags                = local.tags
}

# ---- Azure Container Registry ----
resource "azurerm_container_registry" "acr" {
  name                = lower(local.acr_name) # must be globally unique
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = var.acr_sku # "Basic" | "Standard" | "Premium"
  admin_enabled       = false
  tags                = local.tags
}

# ---- Linux Web App ----
resource "azurerm_linux_web_app" "web" {
  name                = local.webapp_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id
  https_only          = true
  tags                = local.tags

  identity {
    type = "SystemAssigned"
  }

  site_config {
    # We'll deploy a container image via CI/CD. Provide a lightweight runtime as a placeholder.
    application_stack {
      python_version = "3.12"
    }
    always_on = false
    container_registry_use_managed_identity = true
  }

  app_settings = {
    WEBSITES_PORT = "8000" # So App Service forwards traffic to Gunicorn
  }
}

# ---- AcrPull role so Web App's managed identity can pull images from ACR ----
resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_web_app.web.identity[0].principal_id
}
