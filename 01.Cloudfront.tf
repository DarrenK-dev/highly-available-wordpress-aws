resource "aws_cloudfront_distribution" "media" {
  origin {
    domain_name = "highly.available.wordpress.media.s3.eu-west-2.amazonaws.com"
    origin_id   = "media"
  }
  

  enabled         = true
  is_ipv6_enabled = true
  comment         = "Media Distribution"
  # default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "media"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name        = "media"
    Service     = "wordpress"
    Environment = "production"
    Role        = "cloudfront"
    Team        = "devops"
  }

}