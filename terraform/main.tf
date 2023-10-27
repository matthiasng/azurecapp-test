terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.47.0"
    }
    random = {
      version = "3.5.1"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "random_string" "random" {
  length  = 4
  special = false
  lower   = true
  upper   = false
}

locals {
  azure_region = "eu-west"
  name_prefix  = "testcapp"
}

module "azure_region" {
  source  = "claranet/regions/azurerm"
  version = "7.0.0"

  azure_region = local.azure_region
}

resource "azurerm_resource_group" "default" {
  name     = "${local.name_prefix}-rg-${random_string.random.result}"
  location = module.azure_region.location
}

resource "azurerm_log_analytics_workspace" "default" {
  name                = "${local.name_prefix}-log-${random_string.random.result}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "default" {
  name                       = "${local.name_prefix}-cappe-${random_string.random.result}"
  location                   = azurerm_resource_group.default.location
  resource_group_name        = azurerm_resource_group.default.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.default.id
}

resource "azurerm_container_registry" "default" {
  name                = "${local.name_prefix}cr${random_string.random.result}"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_container_app" "service_a" {
  name                         = "${local.name_prefix}-servicea-capp-${random_string.random.result}"
  container_app_environment_id = azurerm_container_app_environment.default.id
  resource_group_name          = azurerm_resource_group.default.name
  revision_mode                = "Single"

  template {
    container {
      name   = "examplecontainerapp"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  ingress {
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
    external_enabled = true
    target_port      = 80
  }

  dapr {
    app_id       = "servicea"
    app_protocol = "grpc"
    app_port     = 80
  }
}

resource "azurerm_container_app" "service_b" {
  name                         = "${local.name_prefix}-serviceb-capp-${random_string.random.result}"
  container_app_environment_id = azurerm_container_app_environment.default.id
  resource_group_name          = azurerm_resource_group.default.name
  revision_mode                = "Single"

  template {
    container {
      name   = "examplecontainerapp"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  ingress {
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
    external_enabled = true
    target_port      = 80
  }

  dapr {
    app_id       = "serviceb"
    app_protocol = "grpc"
    app_port     = 5001
  }
}
