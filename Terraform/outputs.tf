output "bucket_region1_name" {
  value = aws_s3_bucket.multi-dr-s3-region1.bucket
}

output "bucket_region2_name" {
  value = aws_s3_bucket.multi-dr-s3-region2.bucket
}
