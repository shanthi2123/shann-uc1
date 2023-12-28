resource "azurerm_application_gateway" "appgw" {
  name                = var.appgw_name
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  sku {
    name     = var.sku_name
    tier     = var.sku_tier
    capacity = var.sku_capacity
  }
    gateway_ip_configuration {
    name      = var.appgw_ip_configuration
    subnet_id = azurerm_subnet.GatewaySubnet.id
  }

  frontend_port {
    name = var.frontend_port_name
    port = var.port
  }

  frontend_ip_configuration {
    name                 = var.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.appgw-pip.id
  }

  backend_address_pool {
    name = var.backend_address_pool_name
  }

  backend_http_settings {
    name                  = var.http_setting_name
    cookie_based_affinity = var.cookie_based_affinity
    port                  = var.bhs_port
    protocol              = var.bhs_protocol
    path                  = var.path
    request_timeout       = var.request_timeout
  }

  http_listener {
    name                           = var.listener_name
    frontend_ip_configuration_name = var.frontend_ip_configuration_name
    frontend_port_name             = var.frontend_port_name
    protocol                       = var.hl_protocol
  }

  request_routing_rule {
    name                       = var.request_routing_rule_name
    rule_type                  = var.rule_type
    http_listener_name         = var.listener_name
    backend_address_pool_name  = var.backend_address_pool_name
    backend_http_settings_name = var.http_setting_name
    priority                   = var.priority 
  }
}
resource "azurerm_subnet" "GatewaySubnet" {
  name                 = var.GatewaySubnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = var.GatewaySubnet_address_prefixes
}
resource "azurerm_public_ip" "appgw-pip" {
  name                = var.appgw-pip_name
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  allocation_method   = var.appgw-pip_allocation_method
  sku                 = var.appgw-sku
}
resource "azurerm_web_application_firewall_policy" "WAF" {
  name                = var.WAF_name
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location

  custom_rules {
    name      = var.cr_name
    priority  = var.cr_priority
    rule_type = var.cr_rule_type

    match_conditions {
      match_variables {
        variable_name = var.vb_name
      }

      operator           = var.mc_operator
      negation_condition = var.mc_negation_condition
      match_values       = var.mc_match_values
    }

    action = var.mc_action
  }

  custom_rules {
    name      = var.custom_rule_name
    priority  = var.custom_rule_priority
    rule_type = var.custom_rule_type

    match_conditions {
      match_variables {
        variable_name = var.match_variable_name
      }

      operator           = var.match_operator
      negation_condition = var.match_negation_condition
      match_values       = var.match_values
    }

    match_conditions {
      match_variables {
        variable_name = var.variable_name
        selector      = var.match_selector
      }

      operator           = var.operator
      negation_condition = var.negation_condition
      match_values       = var.m_values
    }

    action = var.action
  }

  policy_settings {
    enabled                     = var.policy_setting_enabled
    mode                        = var.policy_setting_mode
    request_body_check          = var.request_body_check
    file_upload_limit_in_mb     = var.file_upload_limit_in_mb
    max_request_body_size_in_kb = var.max_request_body_size_in_kb
  }

  managed_rules {
    exclusion {
      match_variable          = var.match_variable
      selector                = var.selector
      selector_match_operator = var.selector_match_operator
    }
    exclusion {
      match_variable          = var.ex_match_variable
      selector                = var.ex_selector
      selector_match_operator = var.ex_selector_match_operator
    }

    managed_rule_set {
      type    = var.managed_rule_set_type
      version = var.managed_rule_set_version
      rule_group_override {
        rule_group_name = var.rule_group_name
        #rule {
         # id      = "920300"
          #enabled = true
          #action  = "Log"
        #}

        #rule {
         # id      = "920440"
         # enabled = true
          #action  = "Block"
        #}
      }
    }
  }
}
