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
