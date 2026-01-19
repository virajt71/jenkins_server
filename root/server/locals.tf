locals {
  env            = "dev"
  location       = "northeurope"
  name_prefix    = "app-${local.env}"
  admin_username = "azureuser"
  common_tags = {
    environment = local.env
    managed_by  = "terraform"
  }

  terraform        = "../ansible-config/terraform/install_terraform.yml"
  docker           = "../ansible-config/docker/docker.yml"

  install_jenkins  = "${path.root}/../ansible-config/jenkins/install_jenkins.yml"
  jenkins_variables= "${path.root}/../ansible-config/jenkins/variables.yml"

  jenkins_pipeline = "${path.root}/../ansible-config/jenkins/pipeline.yml"
  jenkins_pipeline2 = "${path.root}/../ansible-config/jenkins/pipeline2.yml"

  jenkins_trigger = "${path.root}/../ansible-config/jenkins/trigger.yml"


  # Vault configuration
  vault_file          = "../ansible-config/jenkins/vault/secrets.yml"
  vault_password_file = "../ansible-config/jenkins/vault-pass.txt"
}

variable "subscription_id" {
  type = string
}
