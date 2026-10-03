variable "cluster_name" {
  description = "Nome do cluster Kind a ser provisionado"
  type        = string
  default     = "devops"
}

variable "kubernetes_version" {
  description = "Versão da imagem de node do Kubernetes utilizada pelo Kind (opcional, deixe null para usar o padrão do Kind)"
  type        = string
  default     = null
}
