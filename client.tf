locals {
  app_ui = "app.${var.domain}"
}

resource "aws_s3_bucket" "app_ui" {
  bucket = local.app_ui
  acl    = "private"
}

resource "aws_cloudfront_origin_access_identity" "app_ui" {
}

data "aws_iam_policy_document" "app_ui" {
  statement {
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["${aws_s3_bucket.app_ui.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.app_ui.iam_arn]
    }
  }
}

resource "aws_cloudfront_distribution" "app_ui" {
  origin {
    domain_name = aws_s3_bucket.app_ui.bucket_domain_name
    origin_id   = local.app_ui

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.app_ui.cloudfront_access_identity_path
    }
  }

  aliases             = [local.app_ui]
  enabled             = true
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.app_ui.bucket_domain_name
    prefix          = "cloudfront/"
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.app_ui
    compress               = true
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.main.arn
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  depends_on = [
    aws_s3_bucket.app_ui
  ]
}

resource "aws_route53_record" "app_ui" {
  zone_id = data.aws_route53_zone.main_domain.zone_id
  name    = local.app_ui
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.app_ui.domain_name
    zone_id                = aws_cloudfront_distribution.app_ui.hosted_zone_id
    evaluate_target_health = false
  }
}