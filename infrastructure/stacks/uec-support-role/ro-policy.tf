resource "aws_iam_policy" "ro_policy_1" {
  name        = "uec-ro-secret-services"
  description = "Read-only policies for aws secrets related services"

  policy = file("uec-ro-secret-services.json")
}
resource "aws_iam_policy" "ro_policy_2" {
  name        = "uec-ro-routing-services"
  description = "Read-only policies for aws routing related services"

  policy = file("uec-ro-routing-services.json")
}

resource "aws_iam_policy" "ro_policy_3" {
  name        = "uec-ro-monitoring-services"
  description = "Read-only policies for aws monitoring related services"

  policy = file("uec-ro-monitoring-services.json")
}

resource "aws_iam_policy" "ro_policy_4" {
  name        = "uec-ro-data-services"
  description = "Read-only policies for aws data related services"

  policy = file("uec-ro-data-services.json")
}

resource "aws_iam_policy" "ro_policy_5" {
  name        = "uec-ro-auth-services"
  description = "Read-only policies for aws auth related services"

  policy = file("uec-ro-auth-services.json")
}

resource "aws_iam_policy" "ro_policy_6" {
  name        = "uec-ro-application-services"
  description = "Read-only policies for aws services used by application"

  policy = file("uec-ro-application-services.json")
}

resource "aws_iam_policy" "ro_policy_7" {
  name        = "uec-ro-iam-services"
  description = "Read-only policies for aws IAM services"

  policy = file("uec-ro-iam-services.json")
}
