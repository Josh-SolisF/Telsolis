# Telsolis - Fase 4: VPN con IaC
# Proveedores de Terraform y configuración de AWS.
terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 7.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

provider "aws" {
  region = var.region

  # Etiquetas que se agregan a todo lo que crea Terraform,
  # para reconocer en la consola de AWS qué es del examen.
  default_tags {
    tags = {
      Proyecto = "Telsolis"
      Curso    = "IC-7602"
    }
  }
}
