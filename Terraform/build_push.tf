############################################
# build_push.tf
############################################

############################
# 1) Build & push - FRONTEND
############################
resource "null_resource" "build_and_push_frontend" {
  triggers = {
    image_tag       = var.docker_image_tag
    repository_url  = aws_ecr_repository.frontend_repo.repository_url
    # Podrías añadir un hash de archivos para forzar rebuilds
  }

  provisioner "local-exec" {
    command = <<EOT
      echo "==> Building FRONTEND image..."
      aws ecr get-login-password --region ${var.aws_region} \
        | docker login --username AWS --password-stdin ${aws_ecr_repository.frontend_repo.repository_url}

      docker build -f ../DevOps/Docker/Dockerfile-Frontend \
                   -t frontend:latest \
                   ../student-teacher-app

      docker tag frontend:latest \
        ${aws_ecr_repository.frontend_repo.repository_url}:${var.docker_image_tag}

      docker push \
        ${aws_ecr_repository.frontend_repo.repository_url}:${var.docker_image_tag}
    EOT
    working_dir = "${path.module}/../"
  }
}

############################
# 2) Build & push - BACKEND
############################
resource "null_resource" "build_and_push_backend" {
  triggers = {
    image_tag       = var.docker_image_tag
    repository_url  = aws_ecr_repository.backend_repo.repository_url
  }

  provisioner "local-exec" {
    command = <<EOT
      echo "==> Building BACKEND image..."
      aws ecr get-login-password --region ${var.aws_region} \
        | docker login --username AWS --password-stdin ${aws_ecr_repository.backend_repo.repository_url}

      docker build -f ../DevOps/Docker/Dockerfile-Backend \
                   -t backend:latest \
                   ../backend

      docker tag backend:latest \
        ${aws_ecr_repository.backend_repo.repository_url}:${var.docker_image_tag}

      docker push \
        ${aws_ecr_repository.backend_repo.repository_url}:${var.docker_image_tag}
    EOT
    working_dir = "${path.module}/../"
  }
}

############################
# 3) Build & push - DATABASE
############################
resource "null_resource" "build_and_push_database" {
  triggers = {
    image_tag       = var.docker_image_tag
    repository_url  = aws_ecr_repository.database_repo.repository_url
  }

  provisioner "local-exec" {
    command = <<EOT
      echo "==> Building DATABASE image..."
      aws ecr get-login-password --region ${var.aws_region} \
        | docker login --username AWS --password-stdin ${aws_ecr_repository.database_repo.repository_url}

      docker build -f ../DevOps/Docker/Dockerfile-Database \
                   -t database:latest \
                   ../DevOps/Docker

      docker tag database:latest \
        ${aws_ecr_repository.database_repo.repository_url}:${var.docker_image_tag}

      docker push \
        ${aws_ecr_repository.database_repo.repository_url}:${var.docker_image_tag}
    EOT
    working_dir = "${path.module}/../"
  }
}