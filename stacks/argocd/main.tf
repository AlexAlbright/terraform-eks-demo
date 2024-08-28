provider "argocd" {
  source = "oboukili/argocd"
  version = "6.1.1"

  username = "admin"
  password = "00SdLDtbY3RofsrX"
  port_forward_with_namespace = "argocd"

}


