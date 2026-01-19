# Resource Group
module "resource_group" {
  source = "../../../modules/resource-group"

  name     = "${local.name_prefix}-rg"
  location = local.location
  tags     = local.common_tags
}

# Network
module "network" {
  source = "../../../modules/network"

  name                = "${local.name_prefix}-vnet"
  location            = local.location
  resource_group_name = module.resource_group.name

  address_space = ["10.0.0.0/16"]

  subnets = {
    web = {
      address_prefixes = ["10.0.1.0/24"]
    }
  }

  public_ips = {
    web = {
      allocation_method = "Static"
      sku               = "Standard"
    }
  }

  network_security_groups = {
    web = {
      security_rules = [
        {
          name                       = "SSH"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
        {
          name                       = "HTTP"
          priority                   = 200
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "8080"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    }
  }

  network_interfaces = {
    web = {
      subnet_key                    = "web"
      private_ip_address_allocation = "Dynamic"
      public_ip_key                 = "web"
    }
  }

  nic_nsg_associations = {
    web = {
      nic_key = "web"
      nsg_key = "web"
    }
  }

  tags = local.common_tags
}

# Compute
module "compute" {
  source = "../../../modules/compute"

  name                  = "${local.name_prefix}-vm"
  location              = local.location
  resource_group_name   = module.resource_group.name
  resource_group_id     = module.resource_group.id
  network_interface_ids = module.network.nic_ids

  virtual_machines = {
    web = {
      size                            = "Standard_B2s"
      nic_key                         = "web"
      admin_username                  = local.admin_username
      disable_password_authentication = false # Enable password authentication
      admin_password                  = null  # Will use generated password
      # custom_data = local.cloud_init_content

      os_disk = {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
        disk_size_gb         = 30
      }

      source_image = {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts-gen2"
        version   = "latest"
      }

      tags = local.common_tags
    }
  }

  generate_ssh_key        = false # Generate SSH keys
  generate_admin_password = true  # Generate admin passwords

  tags = local.common_tags
}

# wait for 30 sec for compute to finish
resource "time_sleep" "wait_30_seconds" {
  depends_on      = [module.compute.web]
  create_duration = "30s"
}

# install terraform with ansible
module "terraform" {
  source = "../../../modules/ansible"

  playbook_filename = local.terraform
  host_public_ip    = module.network.public_ip_addresses.web

  vault_pass     = null
  location_files = null

  extra = {
    default = {
      name               = local.admin_username
      password           = module.compute.generated_passwords.web
      python_interpreter = "/usr/bin/python3"
      connection         = "ssh"
      become_password    = module.compute.generated_passwords.web
      ssh_common_args    = "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PubkeyAuthentication=no"
      become_password    = module.compute.generated_passwords.web
    }
  }

  depends_on = [
    time_sleep.wait_30_seconds,
    local.terraform
  ]
}

# install docker with ansible
module "docker" {
  source = "../../../modules/ansible"

  playbook_filename = local.docker
  host_public_ip    = module.network.public_ip_addresses.web

  vault_pass     = null
  location_files = null

  extra = {
    default = {
      name               = local.admin_username
      password           = module.compute.generated_passwords.web
      python_interpreter = "/usr/bin/python3"
      connection         = "ssh"
      become_password    = module.compute.generated_passwords.web
      ssh_common_args    = "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PubkeyAuthentication=no"
      become_password    = module.compute.generated_passwords.web
    }
  }

  depends_on = [
    time_sleep.wait_30_seconds,
    module.terraform
  ]
}

# install jenkins with ansible
module "install_jenkins" {
  source = "../../../modules/ansible"

  playbook_filename = local.install_jenkins
  host_public_ip    = module.network.public_ip_addresses.web

  extra = {
    default = {
      name               = local.admin_username
      password           = module.compute.generated_passwords.web
      python_interpreter = "/usr/bin/python3"
      connection         = "ssh"
      become_password    = module.compute.generated_passwords.web
      ssh_common_args    = "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PubkeyAuthentication=no"
      become_password    = module.compute.generated_passwords.web
    }
  }

  depends_on = [
    time_sleep.wait_30_seconds,
    module.docker
  ]
}

# configure jenkins variable via ansible
module "jenkins_variables" {
  source = "../../../modules/ansible"

  playbook_filename = local.jenkins_variables
  host_public_ip    = module.network.public_ip_addresses.web

  vault_pass     = local.vault_password_file
  location_files = local.vault_file

  extra = {
    default = {
      name               = local.admin_username
      password           = module.compute.generated_passwords.web
      python_interpreter = "/usr/bin/python3"
      connection         = "ssh"
      become_password    = module.compute.generated_passwords.web
      ssh_common_args    = "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PubkeyAuthentication=no"
      become_password    = module.compute.generated_passwords.web
    }
  }

  depends_on = [
    time_sleep.wait_30_seconds,
    module.install_jenkins
  ]
}

# configure pipeline in jenkins via ansible
module "jenkins_pipeline" {
  source = "../../../modules/ansible"

  playbook_filename = local.jenkins_pipeline
  host_public_ip    = module.network.public_ip_addresses.web

  extra = {
    default = {
      name               = local.admin_username
      password           = module.compute.generated_passwords.web
      python_interpreter = "/usr/bin/python3"
      connection         = "ssh"
      become_password    = module.compute.generated_passwords.web
      ssh_common_args    = "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PubkeyAuthentication=no"
      become_password    = module.compute.generated_passwords.web
    }
  }

  depends_on = [
    time_sleep.wait_30_seconds,
    module.jenkins_variables
  ]
}

# configure pipeline in jenkins via ansible
module "jenkins_pipeline" {
  source = "../../../modules/ansible"

  playbook_filename = local.jenkins_pipeline
  host_public_ip    = module.network.public_ip_addresses.web

  extra = {
    default = {
      name               = local.admin_username
      password           = module.compute.generated_passwords.web
      python_interpreter = "/usr/bin/python3"
      connection         = "ssh"
      become_password    = module.compute.generated_passwords.web
      ssh_common_args    = "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PubkeyAuthentication=no"
      become_password    = module.compute.generated_passwords.web
    }
  }

  depends_on = [
    time_sleep.wait_30_seconds,
    module.jenkins_variables
  ]
}

# # Trigger  pipeline in jenkins via ansible
# module "trigger_pipeline" {
#   source = "../../../modules/ansible"

#   playbook_filename = local.jenkins_trigger
#   host_public_ip    = module.network.public_ip_addresses.web

#   extra = {
#     default = {
#       name               = local.admin_username
#       password           = module.compute.generated_passwords.web
#       python_interpreter = "/usr/bin/python3"
#       connection         = "ssh"
#       become_password    = module.compute.generated_passwords.web
#       ssh_common_args    = "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PubkeyAuthentication=no"
#       become_password    = module.compute.generated_passwords.web
#     }
#   }

#   depends_on = [
#     time_sleep.wait_30_seconds,
#     module.jenkins_variables
#   ]
# }
