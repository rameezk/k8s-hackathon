output "azure_subscription_id" {
  value = "${var.azure_subscription_id}"
  sensitive = true
}

output "azure_service_principal_id" {
  value = "${var.azure_service_principal_id}"
  sensitive = true
}

output "azure_service_principal_secret" {
  value = "${var.azure_service_principal_secret}"
  sensitive = true
}

output "azure_tenant_id" {
  value = "${var.azure_tenant_id}"
  sensitive = true
}

output "resource_group" {
  value = "${azurerm_resource_group.k8cluster.name}"
}

output "cluster_name" {
  value = "${var.k8cluster_name}${var.environment}"
}

output "environment" {
  value = "${var.environment}"
}

output "ingress_ip" {
  value = "${data.azurerm_public_ips.ingress_ip.public_ips.0.ip_address}"
}

