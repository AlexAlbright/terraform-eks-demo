output "lb_url" {
  value = data.kubernetes_service.traefik.status.0.load_balancer.0.ingress.0.hostname
}
