data "aws_route53_zone" "main_domain" {
  name = var.domain
}

resource "aws_route53_record" "ping_domain" {
  zone_id = data.aws_route53_zone.main_domain.zone_id
  name    = "ping.${var.domain}"
  type    = "A"

  alias {
    name                   = aws_lb.main_lb.dns_name
    zone_id                = aws_lb.main_lb.zone_id
    evaluate_target_health = false
  }
}