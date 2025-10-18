locals {
  tag_mutability = var.immutable_tags ? "IMMUATBLE" : "MUTABLE"
}

resource "aws_ecr_repository" "this" {
  name                 = var.name
  image_tag_mutability = local.tag_mutability
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
  force_delete = false
  tags         = var.tags
}