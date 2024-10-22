terraform {
  required_providers {
    argocd = {
      source  = "oboukili/argocd"
      version = "6.1.1"
    }
  }
}

# This provider inherits from your current kubeconfig,
# ensure that it's currently pointed at the active cluster before applying
# This is handled if you are using the automated Makefile deployment process
provider "argocd" {
  username     = "admin"
  password     = var.argocd_password
  port_forward = true
  plain_text   = true
}

locals {
  cert_name   = "${var.stack}-cert-${var.environment}"
  issuer_name = "${var.stack}-issuer-${var.environment}"
  fqdn        = "${var.stack}.${var.tld}"
}

data "aws_route53_zone" "hosted_zone" {
  name = "${var.tld}."
}

resource "aws_route53_record" "argocd_dns" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = var.stack
  type    = "CNAME"
  ttl     = "300"
  records = [var.lb_url]
}

resource "kubernetes_namespace" "guestbook_namespace" {
   metadata {
    name = var.stack
  }
}

resource "argocd_application" "guestbook" {
  depends_on = [kubernetes_namespace.guestbook_namespace]
  metadata {
    name = var.stack 
  }

  spec {
    project = "default"

    source {
      repo_url        = "https://github.com/argoproj/argocd-example-apps.git"
      target_revision = "HEAD"
      path            = "guestbook"
    }

    destination {
      server    = "https://kubernetes.default.svc"
      namespace = var.stack
    }

    sync_policy {
     automated {
        prune       = true
        self_heal   = true
        allow_empty = true
      }
    }
  }
}

module "certificates" {
  source      = "./modules/certificates"
  name        = var.stack
  email       = var.email
  environment = var.environment
  tld         = var.tld
}

resource "kubernetes_manifest" "guestbook_ingress" {
  manifest = {
    "apiVersion" = "traefik.io/v1alpha1"
    "kind" = "IngressRoute"
    "metadata" = {
      "name" = "${var.stack}-ingress"
      "namespace" = var.stack 
    }
    "spec" = {
      "entryPoints" = [
        "websecure",
      ]
      "routes" = [
        {
          "kind" = "Rule"
          "match" = "Host(`${local.fqdn}`)"
          "priority" = 10
          "services" = [
            {
              "name" = "guestbook-ui"
              "port" = 80
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
