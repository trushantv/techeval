# S3 bucket for MongoDB backups
# INTENTIONAL WEAKNESS: public read and public listing enabled
resource "aws_s3_bucket" "mongodb_backups" {
  bucket        = "${var.project_name}-mongodb-backups"
  force_destroy = true

  tags = {
    Name = "${var.project_name}-mongodb-backups"
  }
}

# INTENTIONAL WEAKNESS: disabling all public access blocks
resource "aws_s3_bucket_public_access_block" "mongodb_backups" {
  bucket = aws_s3_bucket.mongodb_backups.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# INTENTIONAL WEAKNESS: bucket policy allows public read and listing
resource "aws_s3_bucket_policy" "mongodb_backups" {
  bucket     = aws_s3_bucket.mongodb_backups.id
  depends_on = [aws_s3_bucket_public_access_block.mongodb_backups]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadAndList"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject", "s3:ListBucket"]
        Resource = [
          aws_s3_bucket.mongodb_backups.arn,
          "${aws_s3_bucket.mongodb_backups.arn}/*"
        ]
      }
    ]
  })
}
