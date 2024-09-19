terraform {
  required_providers {
    argocd = {
      source  = "oboukili/argocd"
      version = "6.1.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.32.0"
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

provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}

resource "argocd_application" "guestbook" {
  metadata {
    name = "guestbook"
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
      namespace = "default"
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

resource "argocd_application" "traefik" {
  metadata {
    name = "traefik"
  }
  spec {
    project = "default"

    source {
      repo_url        = "https://traefik.github.io/charts"
      target_revision = "30.1.0"
      chart           = "traefik"
    }

    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "default"
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

resource "argocd_application" "cert-manager" {
  metadata {
    name = "cert-manager"
  }

  spec {
    project = "default"

    source {
      repo_url        = "https://charts.jetstack.io"
      target_revision = "v1.15.3"
      chart           = "cert-manager"
      helm {
        parameter {
          name  = "crds.enabled"
          value = "true"
        }
      }
    }

    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "default"
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

resource "kubernetes_manifest" "argocd_ingress" {
  depends_on = [argocd_application.traefik, argocd_application.cert-manager]
  for_each = fileset("${path.module}/manifests", "*.yaml")
  manifest = yamldecode(file("manifests/${each.value}"))
}

data "kubernetes_service" "traefik" {
  depends_on = [argocd_application.traefik]
  metadata {
    name = "traefik"
  }
}

data "aws_route53_zone" "hosted_zone" {
  name         = "${var.tld}."
}

resource "aws_route53_record" "argocd_dns" {
  depends_on = [argocd_application.traefik]
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = "argocd"
  type    = "CNAME"
  ttl     = "300"
  records = [data.kubernetes_service.traefik.status.0.load_balancer.0.ingress.0.hostname]
}
