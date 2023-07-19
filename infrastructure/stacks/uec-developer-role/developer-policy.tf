resource "aws_iam_policy" "dev_policy_1" {
  name        = "uec-rw-secret-services"
  description = "Read-write policies for aws secrets related services"

  policy = file("uec-rw-secret-services.json")
}
resource "aws_iam_policy" "dev_policy_2" {
  name        = "uec-rw-routing-services"
  description = "Read-write policies for aws routing related services"

  policy = file("uec-rw-routing-services.json")
}

resource "aws_iam_policy" "dev_policy_3" {
  name        = "uec-rw-monitoring-services"
  description = "Read-write policies for aws monitoring related services"

  policy = file("uec-rw-monitoring-services.json")
}

resource "aws_iam_policy" "dev_policy_4" {
  name        = "uec-rw-data-services"
  description = "Read-write policies for aws data related services"

  policy = file("uec-rw-data-services.json")
}

resource "aws_iam_policy" "dev_policy_5" {
  name        = "uec-rw-auth-services"
  description = "Read-write policies for aws auth related services"

  policy = file("uec-rw-auth-services.json")
}

resource "aws_iam_policy" "dev_policy_6" {
  name        = "uec-rw-application-services"
  description = "Read-write policies for aws services used by application"

  policy = file("uec-rw-application-services.json")
}
