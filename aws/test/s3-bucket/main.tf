resource "aws_s3_bucket" "gowri_test_prod1" {
  bucket        = "gowri-test-prod1"
  force_destroy = true

  tags = {
    Name  = "gowri-test-prod1"
    Stack = "s3-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "gowri_test_prod1_public_access_block" {
  bucket = aws_s3_bucket.gowri_test_prod1.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "gowri_test_prod1_encryption" {
  bucket = aws_s3_bucket.gowri_test_prod1.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "gowri_test_prod1_ownership_controls" {
  bucket = aws_s3_bucket.gowri_test_prod1.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}