
module "iam_user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "6.2.1"

  name          = "elio"
  force_destroy = true

  password_reset_required = false
  pgp_key                 = "keybase:test"
  tags = var.default_tags
}

module "iam_group" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group"
  version = "6.2.1"

  name  = "developer"
  users = [module.iam_user.name]

  enable_self_management_permissions = false

  policies = {
    developer-default = module.iam_policy.arn
  }
tags = var.default_tags
}

module "iam_policy" {
  source      = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version     = "6.2.1"
  name        = "developer"
  path        = "/"
  description = "A policy that allows assuming the example role"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole"
        ]
        Effect   = "Allow"
        Resource = module.iam_role.iam_role_arn
      },
    ]
  })
  tags = var.default_tags
}

module "iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.14.0"

  role_name         = "backend"
  create_role       = true
  role_requires_mfa = false

  trusted_role_arns = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  ]
  tags = var.default_tags
}

data "aws_caller_identity" "current" {}
