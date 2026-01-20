locals {
  env            = "env"
  location       = "northeurope"
  name_prefix    = "jenkins-${local.env}"
  admin_username = "azureuser"
  common_tags = {
    environment = local.env
    managed_by  = "terraform"
  }

  terraform        = "../ansible-config/terraform/install_terraform.yml"
  docker           = "../ansible-config/docker/docker.yml"

  install_jenkins  = "${path.root}/../ansible-config/jenkins/install_jenkins.yml"
  jenkins_variables= "${path.root}/../ansible-config/jenkins/variables.yml"

  jenkins_pipeline_entra = "${path.root}/../ansible-config/jenkins/pipeline_entra.yml"
  jenkins_pipeline_entra_scm = "${path.root}/../ansible-config/jenkins/pipeline_entra_scm.yml"

  entra_trigger = "${path.root}/../ansible-config/jenkins/entra_trigger.yml"
  entra_scm_trigger = "${path.root}/../ansible-config/jenkins/entra_scm_trigger.yml"


  # Vault configuration
  vault_file          = "../ansible-config/jenkins/vault/secrets.yml"
  vault_password_file = "../ansible-config/jenkins/vault-pass.txt"

  # Dynamic path for ANSIBLE_VAULT_PASSWORD_FILE (project-relative; works from any clone location)
  ansible_vault_password_file_path = abspath("${path.root}/../ansible-config/jenkins/vault-pass.txt")
}

variable "subscription_id" {
  type = string
}
