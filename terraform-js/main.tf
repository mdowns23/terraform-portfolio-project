provider "aws" {
    region = "us-west-2" #which cloud provider and region to use
}

# S3 Bucket
resource "aws_s3_bucket" "nextjs_bucket" {
    bucket = "nextjs-portfolio-bucket-md"
}

# Ownership Control
# purpose: define ownership of object, only owner can mess with objects
resource "aws_s3_bucket_ownership_controls" "nextjs_bucket_ownership_control" {
  bucket = aws_s3_bucket.nextjs_bucket.id

  rule {
    object_ownership =  "BucketOwnerPreferred" #bucket owner owns ALL objects
  }
}

# Block public Access
# Purpose: provides centralized way to manage public access settings for s3 bucket to prevent unauthorizeed acccess
resource "aws_s3_bucket_public_access_block" "nextjs_bucket_public_access_block" {
  bucket = aws_s3_bucket.nextjs_bucket.id
  
  # all set to false
  block_public_acls = false # prevents application of public acls to bucket/object 
  block_public_policy = false # prevents bucket from having public policy
  ignore_public_acls = false # ignores public acls that are applieed to bucket/object
  restrict_public_buckets = false # restricts making bucket public
}

# Bucket ACL
# Purpose: define granularr access permission to bucket/objects
resource "aws_s3_bucket_acl" "nextjs_bucket_acl" {
  #ensure ownership and public access block is set first
  depends_on = [ 
    aws_s3_bucket_ownership_controls.nextjs_bucket_ownership_control,
    aws_s3_bucket_public_access_block.nextjs_bucket_public_access_block
    ]
  bucket = aws_s3_bucket.nextjs_bucket.id
  acl = "public-read" #sets bucket acl to public read
}

# bucket policy
# Purpose: define detailed access permissions to bucket/object using iam permissions
resource "aws_s3_bucket_policy" "nextjs_bucket_policy" {
  bucket = aws_s3_bucket.nextjs_bucket.id

  #IAM policy
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Sid = "PublicReadGetObject"
            Effect = "Allow"
            Principal = "*"
            Action = "s3:GetObject"
            Resource = "${aws_s3_bucket.nextjs_bucket.arn}/*"
        }
    ]
  })
  
  # wait for block public policy to be set to false
  depends_on = [
    aws_s3_bucket_public_access_block.nextjs_bucket_public_access_block
  ]
}
#using multiple security layers is best practice to prevent unauthorized access
#acl are simpler and provide quick accesss settings
#bucket policy is more granular for bucket/objects

#---Cloudfront--------------------------------------------------------------

# Origin Access Identity
# Purpose: only cloudfront can access s3 bucket
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
    comment = "OAI for Next.JS portfolio site"
  
}

# Cloudfront distribution
# Purpose: cache reduces load times
resource "aws_cloudfront_distribution" "nextjs_distribution" {
  # specifies origin settings for cloudfront distribution
  origin {
    # fetch content from bucket
    domain_name = aws_s3_bucket.nextjs_bucket.bucket_regional_domain_name
    origin_id = "S3-nextjs-portfolio-bucket" #unique origin id in cloudfront
    
    # settings for s3 as the origin, specifies oai that cloudfront uses to access
    # prevents direct access to s3 bucket besides cloudfront
    s3_origin_config {
        origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled = true # cloudfront distribution is active and serves content as soon as created
  is_ipv6_enabled = true # enables ipv6 support for distribution
  comment = "Next.js portfolio site" # comment for distribution to identify purpose
  default_root_object = "index.html" # default root object for distribution

  default_cache_behavior {
    #http methods allowed for caching behavior
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    #common retrieval methods are served quickly
    cached_methods = ["GET", "HEAD"] # specify http methods to cache
    target_origin_id = "S3-nextjs-portfolio-bucket" # links cache behavior to specified origin

    forwarded_values {
      query_string = false # do not forward query strings to origin
      cookies {
        forward = "none" #cookies are not forwarded, improves caching efficiency and reduces complexity
      }
    }

    viewer_protocol_policy = "redirect-to-https" # viewers redirected to https improving security (secure/encrypted)
    min_ttl = 0 #min amount of time an object is cached (immmediate updates if needed)
    default_ttl = 3600 # default amount of time an object is cached, 1hr
    max_ttl = 86400 #max amount of time an object is cached, content refreshed at least every day
  }
  
  #geographical restrictions
  restrictions {
    geo_restriction {
      restriction_type = "none" #none, whitelist or blacklist
    }
  }
  
  #ssl/tls certs
  viewer_certificate {
    #use default certs ssl/tls https
    cloudfront_default_certificate = true #secure connection by using certs
    #custom domains would need a custom cert by using aws cert manager

  }

  
}