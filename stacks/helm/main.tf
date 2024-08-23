provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
      command     = "aws"
    }
  }
}

provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}


resource "kubernetes_namespace" "argocd-namespace" {
  metadata {
    name = "argo"
  }
}

module "argocd_self_managed_helm" {
  source  = "lablabs/eks-argocd/aws"
  version = "0.1.3"
  depends_on = [kubernetes_namespace.argocd-namespace]

  cluster_identity_oidc_issuer     = var.cluster_identity_oidc_issuer
  cluster_identity_oidc_issuer_arn = var.cluster_identity_oidc_issuer_arn

  enabled           = true
  argo_enabled      = true
  argo_helm_enabled = true

  self_managed = true

  helm_release_name = "argocd-helm"
  namespace         = "argocd-helm"

  argo_namespace = "argo"
  argo_sync_policy = {
    "automated" : {}
    "syncOptions" = ["CreateNamespace=true"]
  }

}
