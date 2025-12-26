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
  bucket = aws_s3_bucket.nextjs_bucket
  acl = "public-read" #sets bucket acl to public read
}

# bucket policy
# Purpose: define detailed access permissions to bucket/object using iam permissions
resource "aws_s3_bucket_policy" "nextjs_bucket_policy" {
  bucket = aws_s3_bucket.nextjs_bucket

  #IAM policy
  policy = jjsondecode(({
    version = "2012-10-17"
    Statement = [
        {
            Sid = "PublicReadGetObject"
            Effect = "Allow"
            Principal = "*"
            Action = "s3:GetObject"
            Resource = "${aws_s3_bucket.nextjs_bucket.arn}/*"
        }
    ]
  }))
}
#using multiple security layers is best practice to prevent unauthorized access
#acl are simpler and provide quick accesss settings
#bucket policy is more granular for bucket/objects