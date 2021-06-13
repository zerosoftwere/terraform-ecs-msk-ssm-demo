resource "aws_lb_listener" "main_http" {
  load_balancer_arn = aws_lb.main_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "main_https" {
  load_balancer_arn = aws_lb.main_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-east-1:024027636751:certificate/7c9e7ccf-2284-4353-8c6b-ebaf187f2135"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "test_https" {
  listener_arn = aws_lb_listener.main_https.arn

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "pong"
      status_code  = "200"
    }
  }

  condition {
    host_header {
      values = ["ping.xerosoft.net"]
    }
  }
}