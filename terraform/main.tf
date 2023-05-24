module "acs" {
  source = "github.com/byu-oit/terraform-aws-acs-info.git?ref=v4.0.0"
}

module "codepipeline" {
  source = "github.com/byu-oit/terraform-aws-codepipeline?ref=v1.2.2"
  app_name        = "example"
  repo_name       = "test"
  branch          = "dev"
  github_token    = module.acs.github_token
  deploy_provider = "S3"
  deploy_configuration = {
    BucketName = "test-bucket-${data.aws_caller_identity.current.account_id}"
    Extract    = true
  }
  account_env                   = "dev"
  env_tag                       = "dev"
  role_permissions_boundary_arn = module.acs.role_permissions_boundary.arn
  power_builder_role_arn        = module.acs.power_builder_role.arn
}