resource "aws_iam_policy" "pu_policy_1" {
  name        = "uec-pu-iam-services"
  description = "Read-write policies for aws iam services used by application"

  policy = file("uec-pu-iam-services.json")
}
