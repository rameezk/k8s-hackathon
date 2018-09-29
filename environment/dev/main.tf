module "cluster" {
  source = "../../modules/aks"

  environment = "dev"

  worker_node_vm_count = 3
  worker_node_vm_type = "Standard_D2_v2"
  worker_node_vm_disk_size_gb = 50

  azure_service_principal_id = "${var.azure_service_principal_id}"
  azure_service_principal_secret = "${var.azure_service_principal_secret}"
  azure_subscription_id = "${var.azure_subscription_id}"
  azure_tenant_id = "${var.azure_tenant_id}"
  aad_server_app_id = "${var.aad_server_app_id}"
  aad_server_app_secret = "${var.aad_server_app_secret}"
  aad_client_app_id = "${var.aad_client_app_id}"
  aad_tenant_id = "${var.aad_tenant_id}"
  aad_admins_group_id = "07fbeae6-e110-47d3-b365-efe4d91aae19"
  aks_pod_cidr = "10.18.0.0/16"
  aks_service_cidr = "10.19.0.0/16"

  node_admin_ssh_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDiCGffNWp1VqzTZTMnlQ8W7YP+C0uFd1gwKRaX23rfYgy5uVXJ2dddQ36zlEcdWxsQ0krrYMUhH7bVubNjoI+Jlf+Yz4pHN+PFAAqsxGByubqwFa/Q6gELfzXdTP34P3r2t4q/s26L0LegWjQwHErdmcpRfe963ZxGKmiDLmW1tg+TLy3qrFsE7CyMl9D04yrFORYacjGiT3PeSxU89Iqq8iNnIZ1hTYQuKrGAXjIKj7QaL1WfVfLGcsGkA7XRulBbnFoCVp0ioHc/DHTSo1i0ZFv05UZwTHfJZwZ3XeFNa7xHympOUu4xDY/5h8iE9aSRLpp5PEJdU3zkGHybe/YP QXW0465@LW09766775"

}

