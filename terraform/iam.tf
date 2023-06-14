resource "aws_iam_role" "sc-s3-role" {
  name = "sc-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "schema-conversion.dms.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_role" "sc-secrets-manager-role" {
  name = "sc-secrets-manager-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "dms.us-east-1.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
