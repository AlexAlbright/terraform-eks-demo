terraform {
  required_providers {
    argocd = {
      source  = "oboukili/argocd"
      version = "6.1.1"
    }
  }
}

#provider "kubernetes" {
#  host                   = var.cluster_endpoint
#  cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)
#  exec {
#    api_version = "client.authentication.k8s.io/v1beta1"
#    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
#    command     = "aws"
#  }
#}

provider "argocd" {
  #use_local_config = true
  username     = "admin"
  password     = "00SdLDtbY3RofsrX"
  port_forward = true
  plain_text   = true
  #port_forward_with_namespace = "argocd"
  #server_addr = ""
  #insecure = true
  #kubernetes {
  #  host                   = var.cluster_endpoint
  #  cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)
  #  exec {
  #    api_version = "client.authentication.k8s.io/v1beta1"
  #    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
  #    command     = "aws"
  #  }
  #}
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
