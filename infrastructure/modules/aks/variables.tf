variable "k8cluster_resource_group" {
  description = "The name of the resource group for aks"
  default = "seb-k8s"
}
variable "k8cluster_name" {
  description = "The name of the aks cluster"
  default = "k8s"
}

variable location {
  default = "West Europe"
}

variable worker_node_vm_count {
  default = 3
}

variable worker_node_vm_type {
  default = "Standard_D2_v2"
}

variable worker_node_vm_disk_size_gb {
  default = 50
}

variable "azure_subscription_id" {

}

variable "azure_service_principal_id" {

}

variable "azure_service_principal_secret" {

}

variable "azure_tenant_id" {

}

variable "dns_zone_name" {
  default = "seb.azure.bmw.cloud"
}

variable "dns_zone_resource_group" {
  default = "seb-bmw-dns"
}

variable aad_server_app_id {
  description = "Id of the active directory Web app / API application used by k8 to authenticate with Active Directory"
}

variable aad_server_app_secret {
  description = "secret/password of the active directory Web app / API application used by k8 server to authenticate with Active Directory"
}

variable aad_client_app_id {
  description = "id of the active directory native application used by kubectl to authenticate with Active Directory"
}

variable aad_tenant_id {
  description = "the tenant id of the active directory for user auth"
}

variable "aad_admins_group_id" {
  description = "id of the active directory group for k8s admins"
}

variable environment {
  description = "environment type, possible values are dev,test,qa and prod"
}

variable "node_admin_ssh_key" {
  description = "environment type, possible values are dev,test,qa and prod"
}

variable "aks_pod_cidr" {
  description = "A CIDR notation IP range from which to assign pod IPs when kubenet is used."
}

variable "aks_service_cidr" {
  description = "A CIDR notation IP range from which to assign service cluster IPs."
}

