
variable "azure_service_principal_id" {
    description = "Id of the service principal to use for creating k8 cluster"
}
variable "azure_service_principal_secret" {
    description = "secret/password of the service principal to use for creating k8 cluster"
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


variable "azure_subscription_id" {
    description = "the id of the azure subscription you want to create the cluster in"
}

variable "azure_tenant_id" {
    description = "tenant id of the subscription"
}

