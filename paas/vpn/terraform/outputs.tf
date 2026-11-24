output "ip_publica" {
  description = "IP fija del servidor de la VPN"
  value       = aws_eip.vpn.public_ip
}

output "ssh" {
  description = "Comando para entrar al servidor"
  value       = "ssh -i ${var.llave_privada} ubuntu@${aws_eip.vpn.public_ip}"
}

output "ssh_permitido_desde" {
  description = "IP desde la que se permite SSH (la de quien corrió Terraform)"
  value       = local.mi_ip
}
