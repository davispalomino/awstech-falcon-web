resource "aws_cloudfront_origin_access_identity" "this" {}

resource "aws_cloudfront_distribution" "this" {
    origin {
        domain_name = aws_s3_bucket.this.bucket_regional_domain_name
        origin_id   = aws_s3_bucket.this.id

        s3_origin_config {
            origin_access_identity = aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path
        }
    }

    enabled             = true
    is_ipv6_enabled     = false
    default_root_object = "index.html"

    default_cache_behavior {
        target_origin_id       = aws_s3_bucket.this.id
        viewer_protocol_policy = "redirect-to-https"
        allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
        cached_methods         = ["GET", "HEAD"]
        forwarded_values {
            query_string = false
            cookies {
                forward = "none"
            }
        }
        smooth_streaming = false
        compress         = true
    }

    price_class  = "PriceClass_100"
    http_version = "http2"
    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }

    tags = {
        Service = var.service
        Project = var.project
        Env     = var.env
    }
    
    viewer_certificate {
        cloudfront_default_certificate = true
    }

    custom_error_response {
        error_code            = 404
        response_code         = 200
        response_page_path    = "/index.html"
        error_caching_min_ttl = 60
    }
}