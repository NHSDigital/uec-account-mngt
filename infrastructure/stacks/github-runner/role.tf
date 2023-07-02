
# aws_iam_role_policy = an inline policy
# aws_iam_policy, that is a managed policy and can be re-used

resource "aws_iam_role_policy" "runner_policy_1" {
  name = "Github_runner_policy"
  role = aws_iam_role.github_runner_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role" "github_runner_role" {
  name = "GitHub_Runner"
  assume_role_policy = <<EOF
    {
      "Version":"2012-10-17",
      "Statement":[
        {
          "Effect":"Allow",
          "Principal":{
            "Federated":"arn:aws:iam::${local.account_id}:oidc-provider/token.actions.githubusercontent.com"
          },
          "Action":"sts:AssumeRoleWithWebIdentity",
          "Condition":{
            "ForAllValues:StringLike":{
                "token.actions.githubusercontent.com:sub":"repo:${var.repo_name}:*",
                "token.actions.githubusercontent.com:aud":"sts.amazonaws.com"
              }
          }
        }
      ]
    }
    EOF
}
