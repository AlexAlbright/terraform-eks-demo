output "argocd_admin_setup_password" {
  value     = data.kubernetes_secret.argocd_admin_setup_password.data
  sensitive = true
}
