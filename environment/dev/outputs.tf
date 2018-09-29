
output "mdm_service_bus_namespace" {
  value = "${module.cluster.mdm_service_bus_namespace}"
}
output "mdm_service_bus_connection_string" {
  value = "${module.cluster.mdm_service_bus_connection_string}"
}

output "eventhub_namespace_key" {
  value = "${module.cluster.eventhub_namespace_key}"
}

output "eventhub_namespace" {
  value = "${module.cluster.eventhub_namespace}"
}

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

output "eventhub_connection_string" {
  value = "${module.cluster.event_hub_connection_string}"
}