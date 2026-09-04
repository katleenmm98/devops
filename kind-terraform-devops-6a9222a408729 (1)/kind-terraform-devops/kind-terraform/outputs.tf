output "cluster_name" {
  description = "Nome do cluster Kind provisionado"
  value       = kind_cluster.devops.name
}

output "kubeconfig_path" {
  description = "Caminho do kubeconfig gerado para o cluster"
  value       = kind_cluster.devops.kubeconfig_path
}

output "client_certificate" {
  description = "Certificado do cliente (sensível, apenas para referência)"
  value       = kind_cluster.devops.client_certificate
  sensitive   = true
}

output "endpoint" {
  description = "Endpoint da API do Kubernetes"
  value       = kind_cluster.devops.endpoint
}
