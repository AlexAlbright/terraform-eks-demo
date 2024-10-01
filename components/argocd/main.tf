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

module "certificates" {
  source      = "./modules/certificates"
  name        = var.stack
  email       = var.email
  environment = var.environment
  tld         = var.tld
}

resource "kubernetes_manifest" "ingress_route" {
  manifest = {
    "apiVersion" = "traefik.io/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata" = {
      "name"      = "${var.stack}-ingress"
      "namespace" = var.stack
    }
    "spec" = {
      "entryPoints" = [
        "websecure",
      ]
      "routes" = [
        {
          "kind"     = "Rule"
          "match"    = "Host(`${local.fqdn}`)"
          "priority" = 10
          "services" = [
            {
              "name" = "argocd-server"
              "port" = 80
            },
          ]
        },
        {
          "kind"     = "Rule"
          "match"    = "Host(`${local.fqdn}`) && Header(`Content-Type`, `application/grpc`)"
          "priority" = 11
          "services" = [
            {
              "name"   = "argocd-server"
              "port"   = 80
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
