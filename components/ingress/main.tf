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

module "certificates" {
  source = "./modules/certificates"

  name = "argocd"
  email = "alexalbright@me.com"
  environment = var.environment
  tld = "alexalbright.com"
}

resource "kubernetes_manifest" "argocd_ingress_route" {
  manifest = {
    "apiVersion" = "traefik.io/v1alpha1"
    "kind" = "IngressRoute"
    "metadata" = {
      "name" = "argocd-ingress"
      "namespace" = "argocd" 
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
        "secretName" = "argocd-cert-${var.environment}" 
      }
    }
  }
}

data "kubernetes_service" "traefik" {
  depends_on = [argocd_application.traefik]
  metadata {
    name = "traefik"
  }
}

resource "aws_route53_record" "argocd_dns" {
  depends_on = [argocd_application.traefik]
  zone_id    = "Z03856972BWR1NS86YG6P" # hardcode, figure this out later
  name       = "argocd"
  type       = "CNAME"
  ttl        = "300"
  records    = [data.kubernetes_service.traefik.status.0.load_balancer.0.ingress.0.hostname]
}
