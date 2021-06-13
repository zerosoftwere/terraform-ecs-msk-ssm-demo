resource "aws_lb" "main_lb" {
  name                       = "main-lb"
  internal                   = false
  load_balancer_type         = "application"
  subnets                    = [aws_subnet.main_subnet_1.id, aws_subnet.main_subnet_2.id, aws_subnet.main_subnet_3.id]
  enable_deletion_protection = false

  security_groups = [
    aws_security_group.allow_all_in_sg.id,
    aws_security_group.allow_all_out_sg.id,
    aws_security_group.allow_cluster_ports_sg.id
  ]

  access_logs {
    bucket  = aws_s3_bucket.lb_logs.bucket
    prefix  = "lb-logs"
    enabled = true
  }

  depends_on = [
    aws_s3_bucket_policy.lb_bucket_policy
  ]

  tags = {
    Name = "cluster-lb"
  }
}

resource "aws_s3_bucket" "lb_logs" {
  bucket = "lb-logs-${var.domain}"
  acl    = "private"

  tags = {
    Name = "lb-logs"
  }
}

resource "aws_s3_bucket_policy" "lb_bucket_policy" {
  bucket = aws_s3_bucket.lb_logs.bucket
  policy = data.aws_iam_policy_document.s3_lb_policy_doc.json
}

data "aws_elb_service_account" "main" {

}