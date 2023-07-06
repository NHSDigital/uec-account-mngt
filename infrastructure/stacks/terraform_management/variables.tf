variable "project" {
  description = "Project code typically reflects sub project of project owner eg nhse-uec-dos"
}
variable "project_owner" {
  description = "Project owner based on orgnaistion and department code eg nhse-uec"
}
variable "environment" {
  description = "The environment - dev, test, staging etc"
}
variable "account_alias" {
  description = "Alias for AWS account - usually equal to account name"
}
