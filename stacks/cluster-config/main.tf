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
    name = "argocd"
  }
}

resource "kubernetes_manifest" "argocd-manifest" {
  depends_on = [kubernetes_namespace.argocd-namespace]
  manifest   = yamldecode(file("manifests/argocd.yaml"))
}

# Part of the steps to allow more pods per node
#resource "kubernetes_manifest" "aws_node_env_patch" {
#  manifest = {
#    "apiVersion" = "apps/v1"
#    "kind"       = "DaemonSet"
#    "metadata" = {
#      "name"      = "aws-node"
#      "namespace" = "kube-system"
#    }
#    "spec" = {
#      "template" = {
#        "metadata" = {
#          "annotations" = {
#            "kubectl.kubernetes.io/last-applied-configuration" = jsonencode({
#              "env" = [{
#                "name"  = "ENABLE_PREFIX_DELEGATION"
#                "value" = "true"
#              }]
#            })
#          }
#        }
#        "spec" = {
#          "containers" = [{
#            "name" = "aws-node"
#            "env" = [{
#              "name"  = "ENABLE_PREFIX_DELEGATION"
#              "value" = "true"
#            }]
#          }]
#        }
#      }
#    }
#  }
#}
