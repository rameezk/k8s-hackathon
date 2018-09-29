output "ingress_ip" {
  value = "${module.cluster.ingress_ip}"
}

output "azure_subscription_id" {
  value = "${module.cluster.azure_subscription_id}"
}

output "azure_service_principal_id" {
  value = "${module.cluster.azure_service_principal_id}"
}

output "azure_service_principal_secret" {
  value = "${module.cluster.azure_service_principal_secret}"
}

output "azure_tenant_id" {
  value = "${module.cluster.azure_tenant_id}"
}

output "resource_group" {
  value = "${module.cluster.resource_group}"
}

output "cluster_name" {
  value = "${module.cluster.cluster_name}"
}
