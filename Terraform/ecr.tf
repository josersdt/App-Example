############################################
# ecr.tf
############################################

resource "aws_ecr_repository" "frontend_repo" {
  name = "frontend-repo"
}

resource "aws_ecr_repository" "backend_repo" {
  name = "backend-repo"
}

resource "aws_ecr_repository" "database_repo" {
  name = "database-repo"
}
