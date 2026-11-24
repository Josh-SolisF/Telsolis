# Telsolis - variables de la infraestructura de la VPN

variable "region" {
  description = "Región de AWS donde se crea todo"
  type        = string
  default     = "us-east-1"
}

variable "tipo_instancia" {
  description = "Tamaño del servidor (t3.micro entra en la capa gratuita)"
  type        = string
  default     = "t3.micro"
}

variable "encendida" {
  description = <<-EOT
    true: existe el servidor. false: se borra el servidor pero se conserva la IP fija,
    para no cambiar el DNS del dominio (Fase 5) cada vez que se apaga.
  EOT
  type        = bool
  default     = true
}

variable "llave_publica" {
  description = "Llave SSH pública que se instala en el servidor"
  type        = string
  default     = "~/.ssh/telsolis-aws.pub"
}

variable "llave_privada" {
  description = "Llave SSH privada con la que Ansible entra al servidor (no sale de la VM docker)"
  type        = string
  default     = "~/.ssh/telsolis-aws"
}
