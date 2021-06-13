data "aws_acm_certificate" "main" {
  domain   = "*.${var.domain}"
  statuses = ["ISSUED"]
}