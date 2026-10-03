resource "kind_cluster" "devops" {
  name           = var.cluster_name
  wait_for_ready = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    # 1 node de control-plane (gerencia o cluster: API Server, etcd, Scheduler, Controller Manager)
    node {
      role  = "control-plane"
      image = var.kubernetes_version != null ? "kindest/node:${var.kubernetes_version}" : null
    }

    # 2 nodes worker (executam as cargas de trabalho / pods das aplicações)
    node {
      role  = "worker"
      image = var.kubernetes_version != null ? "kindest/node:${var.kubernetes_version}" : null
    }

    node {
      role  = "worker"
      image = var.kubernetes_version != null ? "kindest/node:${var.kubernetes_version}" : null
    }
  }
}
