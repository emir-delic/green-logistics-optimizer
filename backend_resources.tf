resource "aws_s3_bucket" "terraform_state" {
  bucket        = "green-logistics-optimizer-state-storage-edelic"
  force_destroy = true 
}

resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}