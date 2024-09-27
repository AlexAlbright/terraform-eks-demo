# This module defines a few key components for each web app deployed to the cluster 
# 1. Certificate issuer
# 2. Certificate
# 3. Ingress Route

locals {
  cert_name = "${var.name}-cert-${var.environment}"
  issuer_name = "${var.name}-issuer-${var.environment}"
  fqdn = "${var.name}.${var.tld}"
}

resource "kubernetes_manifest" "certificate" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind" = "Certificate"
    "metadata" = {
      "name" = local.cert_name 
      "namespace" = var.name 
    }
    "spec" = {
      "commonName" = local.fqdn 
      "dnsNames" = [
        local.fqdn,
      ]
      "issuerRef" = {
        "kind" = "Issuer"
        "name" = local.issuer_name 
      }
      "secretName" = local.cert_name 
    }
  }
}

resource "kubernetes_manifest" "certificate_issuer" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind" = "Issuer"
    "metadata" = {
      "name" = local.issuer_name 
      "namespace" = var.name 
    }
    "spec" = {
      "acme" = {
        "email" = var.email 
        "privateKeySecretRef" = {
          "name" = "letsencrypt-issuer-account-key"
        }
        "server" = "https://acme-v02.api.letsencrypt.org/directory"
        "solvers" = [
          {
            "http01" = {
              "ingress" = {
                "ingressClassName" = "traefik"
                "serviceType" = "ClusterIP"
              }
            }
          },
        ]
      }
    }
  }
}

resource "kubernetes_manifest" "ingress_route" {
  manifest = {
    "apiVersion" = "traefik.io/v1alpha1"
    "kind" = "IngressRoute"
    "metadata" = {
      "name" = "${var.name}-ingress"
      "namespace" = var.name 
    }
    "spec" = {
      "entryPoints" = [
        "websecure",
      ]
      "routes" = [
        {
          "kind" = "Rule"
          "match" = "Host(`argocd.alexalbright.com`)"
          "priority" = 10
          "services" = [
            {
              "name" = "argocd-server"
              "port" = 80
            },
          ]
        },
        {
          "kind" = "Rule"
          "match" = "Host(`argocd.alexalbright.com`) && Header(`Content-Type`, `application/grpc`)"
          "priority" = 11
          "services" = [
            {
              "name" = "argocd-server"
              "port" = 80
              "scheme" = "h2c"
            },
          ]
        },
      ]
      "tls" = {
        "secretName" = local.cert_name 
      }
    }
  }
}
