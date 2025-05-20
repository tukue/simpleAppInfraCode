resource "local_file" "ansible_inventory_template" {
  content = <<-EOT
[eks_nodes]
%{for ip in module.eks.worker_node_ips}
${ip} ansible_user=ec2-user
%{endfor}

[eks_nodes:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
  EOT
  
  filename = "${path.module}/inventory"
}

resource "null_resource" "ansible_executor" {
  depends_on = [local_file.ansible_inventory_template, module.eks]

  provisioner "local-exec" {
    command = "ansible-playbook -i inventory ansible-playbook.yml"
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}