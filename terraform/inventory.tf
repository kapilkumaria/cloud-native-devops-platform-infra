resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../inventory.ini"

  content = <<EOF
[app_servers]
${aws_instance.app.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/home/ubuntu/.ssh/devops11.pem app_public_ip=${aws_instance.app.public_ip}
EOF
}
