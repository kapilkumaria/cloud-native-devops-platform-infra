resource "null_resource" "run_ansible" {
  depends_on = [
    aws_instance.app,
    local_file.ansible_inventory
  ]

  provisioner "local-exec" {
    command = "sleep 60 && cd ${path.module}/.. && ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook -i inventory.ini ansible/playbooks/site.yml"
  }
}
