resource "aws_s3_bucket" "cg-athena-bucketresult" {
  bucket = "cg-${var.cgid}-athena-bucketresult"
  force_destroy = true
  
  tags = {
    Name = "cg-${var.cgid}-athena-bucketresult"
    Environment = "cloudgoat"
    Scenario = var.scenario_name # 이름 변경해야함
  }
}

resource "aws_s3_bucket" "cg-athena-bucketstorage" {
  bucket = "cg-${var.cgid}-athena-bucketstorage"
  force_destroy = true
  
  tags = {
    Name = "cg-${var.cgid}-athena-bucketstorage"
    Environment = "cloudgoat"
    Scenario = var.scenario_name # 이름 변경해야함
  }
}

resource "aws_s3_object" "flag_parquet" {
  bucket  = aws_s3_bucket.cg-athena-bucketstorage.id
  key     = "flag/flag.parquet"
  source  = "source/flag.parquet"  
  etag = filemd5("${path.module}/../source/flag.parquet")
}

resource "aws_s3_object" "logs_parquet" {
  bucket  = aws_s3_bucket.cg-athena-bucketstorage.id
  key     = "logs/logs.parquet"
  source  = "source/logs.parquet"
  etag = filemd5("${path.module}/../source/logs.parquet")
}

resource "aws_s3_object" "users_parquet" {
  bucket  = aws_s3_bucket.cg-athena-bucketstorage.id
  key     = "users/users.parquet"
  source  = "source/users.parquet"  
  etag = filemd5("${path.module}/../source/users.parquet")
}

