resource "kubernetes_manifest" "argocd_ingress" {
  for_each = fileset("${path.module}/manifests", "*.yaml")
  manifest = yamldecode(file("manifests/${each.value}"))
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
