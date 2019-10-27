locals {
    cluster_name            = "aks-${random_string.aks.result}"
    default_ssh_public_key  = "${file("~/.ssh/id_rsa.pub")}"
    ssh_public_key          = "${var.ssh_public_key != "" ? var.ssh_public_key : local.default_ssh_public_key }"
}


resource "azurerm_resource_group" "aks" {
    name     = "${var.resource_group_name}"
    location = "${var.location}"
}

resource "random_string" "aks" {
  length  = 8
  lower   = true
  number  = true
  upper   = true
  special = false
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${local.cluster_name}"
  location            = "${azurerm_resource_group.aks.location}"
  resource_group_name = "${azurerm_resource_group.aks.name}"
  dns_prefix          = "${local.cluster_name}"
 
  service_principal {
  client_id           = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  client_secret       = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  }

  linux_profile {
    admin_username  = "aksadmin"

    ssh_key {
      key_data = "${local.ssh_public_key}"
    }
  }

  agent_pool_profile {
    name            = "default"
    count           = "${var.agent_count}"
    vm_size         = "${var.vm_size}"
    os_type         = "Linux"
    os_disk_size_gb = 30
  }

  tags              = "${var.tags}"
}

resource "kubernetes_pod" "test" {
  metadata {
    name = "terraform-example"
  }

  spec {
    container {
      image = "nginx:1.7.9"
      name  = "example"
    }
  }
}
