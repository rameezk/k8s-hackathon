module "cluster" {
  source = "../../modules/aks"

  environment = "dev"

  worker_node_vm_count = 2
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
  aad_admins_group_id = "6ba5839f-fc8b-4ae9-b26d-ae71df5d1145"
  aks_pod_cidr = "10.18.0.0/16"
  aks_service_cidr = "10.19.0.0/16"

  node_admin_ssh_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDiCGffNWp1VqzTZTMnlQ8W7YP+C0uFd1gwKRaX23rfYgy5uVXJ2dddQ36zlEcdWxsQ0krrYMUhH7bVubNjoI+Jlf+Yz4pHN+PFAAqsxGByubqwFa/Q6gELfzXdTP34P3r2t4q/s26L0LegWjQwHErdmcpRfe963ZxGKmiDLmW1tg+TLy3qrFsE7CyMl9D04yrFORYacjGiT3PeSxU89Iqq8iNnIZ1hTYQuKrGAXjIKj7QaL1WfVfLGcsGkA7XRulBbnFoCVp0ioHc/DHTSo1i0ZFv05UZwTHfJZwZ3XeFNa7xHympOUu4xDY/5h8iE9aSRLpp5PEJdU3zkGHybe/YP QXW0465@LW09766775"

}


resource "helm_release" "capture_order" {
  name      = "captureorder"
  chart     = "../../helm/captureorder"
  namespace = "hackathon"
  depends_on = ["module.cluster","null_resource.capture_order_certificate"]
  force_update = true
  recreate_pods = true

  set {
    name = "mongoUrl"
    value = "mongodb://paradise:paradise@mongo-mongodb.hackathon"
  }

  set {
    name = "rabbitMqUrl"
    value = "amqp://paradise:paradise@rabbitmq:5672"
  }

  set {
    name  = "ingress.enabled"
    value = "true"
  }

  set {
    name  = "ingress.hosts[0]"
    value = "captureorder.apps.paradise-pd-k8s-hackathon.tk"
  }

  set {
    name  = "ingress.tls[0].hosts[0]"
    value = "captureorder.apps.paradise-pd-k8s-hackathon.tk"
  }

  set {
    name  = "ingress.tls[0].secretName"
    value = "capture-order-tls"
  }

  set {
    name = "ingress.path"
    value = "captureorder.apps.paradise-pd-k8s-hackathon.tk"
  }

}


resource "null_resource" "capture_order_certificate" {

  triggers {
    namespace = "1"
  }


  depends_on = ["module.cluster"]

  provisioner "local-exec" {
    command = <<EOT

cat <<EOF | kubectl apply -f -
apiVersion: certmanager.k8s.io/v1alpha1
kind: Certificate
metadata:
  name: capture-order-tls
  namespace: hackathon
spec:
  secretName: capture-order-tls
  dnsNames:
  - captureorder.apps.paradise-pd-k8s-hackathon.tk
  acme:
    config:
    - http01:
        ingressClass: nginx
      domains:
      - captureorder.apps.paradise-pd-k8s-hackathon.tk
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
EOF

EOT
  }
}


resource "helm_release" "mongo" {
  name      = "mongo"
  version   = "2.0.0"
  chart     = "stable/mongodb"
  namespace = "hackathon"
  depends_on = ["module.cluster"]
  force_update = true
  recreate_pods = true

  #TODO: change username and password
  set {
    name = "mongodbUsername"
    value = "paradise"
  }
  set {
    name = "mongodbPassword"
    value = "paradise"
  }
  set {
    name = "mongodbDatabase"
    value = "k8orders"
  }
  set {
    name = "mongodbRootPassword"
    value = "paradise"
  }
}

resource "helm_release" "fulfill_order" {
  name      = "fulfillorder"
  chart     = "../../helm/fulfillorder"
  namespace = "hackathon"
  depends_on = ["module.cluster", "null_resource.azure_file_storage_class"]
  force_update = true
  recreate_pods = true

  set {
    name = "mongoUrl"
    value = "mongodb://paradise:paradise@mongo-mongodb.hackathon"
  }

}

resource "helm_release" "rabbiqmq" {
  name      = "rabbitmq"
  chart     = "stable/rabbitmq"
  namespace = "hackathon"
  depends_on = ["module.cluster"]
  force_update = true
  recreate_pods = true

  set {
    name = "rabbitmq.username"
    value = "paradise"
  }

  set {
    name = "rabbitmq.password"
    value = "paradise"
  }
}

resource "helm_release" "eventlistener" {
  name      = "eventlistener"
  chart     = "../../helm/eventlistener"
  namespace = "hackathon"
  depends_on = ["module.cluster"]
  force_update = true
  recreate_pods = true

  set {
    name = "rabbitMqUrl"
    value = "amqp://paradise:paradise@rabbitmq:5672"
  }

  set {
    name = "processedEndpoint"
    value = "http://fulfillorder.hackathon:8080/v1/order"
  }

}

resource "null_resource" "azure_file_storage_class" {

  triggers {
    namespace = "4"
  }


  depends_on = ["module.cluster"]

  provisioner "local-exec" {
    command = <<EOT

cat <<EOF | kubectl apply -f -
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: azurefile
provisioner: kubernetes.io/azure-file
mountOptions:
  - dir_mode=0777
  - file_mode=0777
  - uid=1000
  - gid=1000
parameters:
  skuName: Standard_LRS
  storageAccount: paradisepdstorage
EOF

EOT
  }
}


