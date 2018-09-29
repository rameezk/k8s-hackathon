
provider "azurerm" {
  version = "~>1.5"

  subscription_id = "${var.azure_subscription_id}"
  client_id = "${var.azure_service_principal_id}"
  client_secret = "${var.azure_service_principal_secret}"
  tenant_id = "${var.azure_tenant_id}"
}


resource "null_resource" "az_cli_login" {

  triggers {
    timestamp = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "az login --service-principal -u ${var.azure_service_principal_id} -p ${var.azure_service_principal_secret} --tenant ${var.azure_tenant_id}"
  }

}


resource "azurerm_resource_group" "k8cluster" {
  name     = "${var.k8cluster_resource_group}-${var.environment}"
  location = "${var.location}"

  tags {
    created-by = "terraform"
    environment = "${var.environment}"
  }
}


resource "null_resource" "az_cli_k8cluster" {

  triggers {
    environment = "${var.environment}"
  }

  depends_on = ["null_resource.az_cli_login","azurerm_resource_group.k8cluster"]

  provisioner "local-exec" {
    on_failure = "fail"
    command = <<EOT

az aks create --resource-group ${azurerm_resource_group.k8cluster.name} --name ${var.k8cluster_name}${var.environment} --generate-ssh-keys \
  --node-vm-size ${var.worker_node_vm_type} \
  --aad-server-app-id ${var.aad_server_app_id} \
  --aad-server-app-secret ${var.aad_server_app_secret} \
  --aad-client-app-id ${var.aad_client_app_id} \
  --aad-tenant-id ${var.aad_tenant_id} \
  --node-count ${var.worker_node_vm_count} \
  --node-osdisk-size ${var.worker_node_vm_disk_size_gb}

EOT
  }

  provisioner "local-exec" {
    when = "destroy"
    command = "az aks delete --resource-group ${azurerm_resource_group.k8cluster.name} --name ${var.k8cluster_name}${var.environment} --no-wait --yes"
  }


}




resource "null_resource" "kubectl_admin_credentials" {

  triggers {
    timestamp = "${timestamp()}"
  }

  depends_on = ["null_resource.az_cli_k8cluster"]

  provisioner "local-exec" {
    command = "az aks get-credentials --resource-group ${azurerm_resource_group.k8cluster.name} --name ${var.k8cluster_name}${var.environment} --admin"
  }
}



resource "null_resource" "k8sAADadminGroup" {

  triggers{
    group_id = "${var.aad_admins_group_id}"
  }

  depends_on = ["null_resource.kubectl_admin_credentials"]

  provisioner "local-exec" {
    command = <<EOT

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
 name: k8-terraform-admins
roleRef:
 apiGroup: rbac.authorization.k8s.io
 kind: ClusterRole
 name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: "${var.aad_admins_group_id}"
EOF

EOT
  }
}


resource "null_resource" "helmK8sServiceAccount" {

  triggers {
    environment = "${var.environment}"
  }


  depends_on = ["null_resource.kubectl_admin_credentials"]

  provisioner "local-exec" {
    command = <<EOT

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
EOF

EOT
  }
}


resource "null_resource" "initialise_helm" {

  triggers {
    environment = "${var.environment}"
  }

  depends_on = ["null_resource.kubectl_admin_credentials","null_resource.helmK8sServiceAccount"]

  provisioner "local-exec" {
    command = "helm init --service-account tiller"
  }

  provisioner "local-exec" {
    command = "sleep 1m"
  }
}



resource "null_resource" "ingress_controller" {

  depends_on = ["null_resource.initialise_helm","null_resource.kubectl_admin_credentials"]

  provisioner "local-exec" {
    command = <<EOT

    helm install stable/nginx-ingress --name ingress-controller --namespace kube-system

    EOT
  }

  provisioner "local-exec" {
    command = "sleep 1m"
  }

  provisioner "local-exec" {
    when = "destroy"
    command = "helm delete ingress-controller --purge"
  }
}


data "azurerm_public_ips" "ingress_ip" {

  depends_on = ["null_resource.ingress_controller"]
  resource_group_name = "MC_${var.k8cluster_resource_group}-${var.environment}_${var.k8cluster_name}${var.environment}_westeurope"
}


resource "null_resource" "configure_dns_for_ip" {
  depends_on = ["null_resource.ingress_controller"]

  provisioner "local-exec" {
    command = "az network public-ip update --ids ${data.azurerm_public_ips.ingress_ip.public_ips.0.id} --dns-name ${var.environment}-aks-ingress"
  }
}


resource "null_resource" "cert_manager" {


  depends_on = ["null_resource.ingress_controller","null_resource.kubectl_admin_credentials"]

  provisioner "local-exec" {
    command = <<EOT

    helm install stable/cert-manager --name cert-manager --set ingressShim.defaultIssuerName=letsencrypt-prod --set ingressShim.defaultIssuerKind=ClusterIssuer

    EOT
  }

  provisioner "local-exec" {
    when = "destroy"
    command = "helm delete cert-manager --purge"
  }
}



resource "null_resource" "cluster_issuer" {

  triggers {
    environment = "${var.environment}"
  }

  depends_on = ["null_resource.initialise_helm","null_resource.cert_manager","null_resource.kubectl_admin_credentials"]

  provisioner "local-exec" {
    command = <<EOT

cat <<EOF | kubectl apply -f -
apiVersion: certmanager.k8s.io/v1alpha1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: kagudaprince@gmail.com
    privateKeySecretRef:
      name: letsencrypt-prod
    http01: {}
EOF

EOT
  }
}






