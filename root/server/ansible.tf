# wait for 30 sec for compute to finish
resource "time_sleep" "wait_30_seconds" {
  depends_on      = [module.compute.web]
  create_duration = "30s"
}

# install terraform with ansible
module "terraform" {
  source = "../../modules/ansible"

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
  source = "../../modules/ansible"

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

  depends_on = [ module.terraform ]
}

# install jenkins with ansible
module "install_jenkins" {
  source = "../../modules/ansible"

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

  depends_on = [ module.docker ]
}

# configure jenkins variable via ansible
module "jenkins_variables" {
  source = "../../modules/ansible"

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

  depends_on = [ module.install_jenkins ]
}

# configure pipeline in jenkins via ansible
module "jenkins_pipeline_entra" {
  source = "../../modules/ansible"

  playbook_filename = local.jenkins_pipeline_entra
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

  depends_on = [ module.jenkins_variables ]
}

# Trigger  pipeline in jenkins via ansible
module "entra_trigger" {
  source = "../../../modules/ansible"

  playbook_filename = local.entra_trigger
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

  depends_on = [ module.jenkins_pipeline_entra ]
}

# configure pipeline in jenkins via ansible
module "jenkins_pipeline_entra_scm" {
  source = "../../modules/ansible"

  playbook_filename = local.jenkins_pipeline_entra_scm
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

  depends_on = [ module.jenkins_variables ]
}

# Trigger  pipeline in jenkins via ansible
module "entra_scm_trigger" {
  source = "../../../modules/ansible"

  playbook_filename = local.entra_scm_trigger
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

  depends_on = [ module.jenkins_pipeline_entra_scm ]
}
