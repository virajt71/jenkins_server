resource "ansible_playbook" "this" {
  for_each = var.extra

  playbook   = var.playbook_filename
  name       = var.host_public_ip
  replayable = var.replayable

  vault_password_file = var.vault_pass != null ? var.vault_pass : null
  var_files           = var.location_files != null ? [var.location_files] : []

  extra_vars = {
    ansible_user               = each.value.name
    ansible_password           = each.value.password
    ansible_python_interpreter = each.value.python_interpreter
    ansible_connection         = each.value.connection
    ansible_ssh_common_args    = each.value.ssh_common_args
    ansible_become_password    = each.value.become_password
    ansible_host_key_checking  = each.value.host_key_checking
  }
}
