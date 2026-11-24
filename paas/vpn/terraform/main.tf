# Telsolis - Fase 4: servidor de la VPN en AWS
#
# Crea: llave SSH, firewall (security group), servidor Ubuntu 24.04 (EC2)
# y una IP pública fija (Elastic IP). Al final genera el inventario de Ansible.

# IP pública desde donde se corre Terraform: solo ella puede entrar por SSH.
data "http" "mi_ip" {
  url = "https://checkip.amazonaws.com"
}

locals {
  mi_ip = "${chomp(data.http.mi_ip.response_body)}/32"
}

# Imagen oficial de Ubuntu 24.04 LTS publicada por Canonical (dueño 099720109477).
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "telsolis" {
  key_name   = "telsolis-aws"
  public_key = file(pathexpand(var.llave_publica))
}

# Firewall: OpenVPN abierto a internet, SSH solo desde nuestra IP.
resource "aws_security_group" "vpn" {
  name        = "telsolis-vpn"
  description = "Telsolis: OpenVPN (TCP 1194 TAP, TCP 1195 TUN) y SSH de administracion"

  ingress {
    description = "OpenVPN TAP (computadora)"
    from_port   = 1194
    to_port     = 1194
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "OpenVPN TUN (telefono)"
    from_port   = 1195
    to_port     = 1195
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Fase 5: DNS autoritativo de telsolis.tech y sitio web público
  ingress {
    description = "DNS (UDP) - BIND autoritativo de telsolis.tech"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "DNS (TCP) - BIND autoritativo de telsolis.tech"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP - sitio publico (y validacion de Lets Encrypt)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS - sitio publico"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH solo desde la IP de quien corre Terraform"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.mi_ip]
  }

  egress {
    description = "Salida libre (el servidor rutea el trafico de la VPN a internet)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "vpn" {
  count = var.encendida ? 1 : 0

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.tipo_instancia
  key_name               = aws_key_pair.telsolis.key_name
  vpc_security_group_ids = [aws_security_group.vpn.id]

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  # Exige IMDSv2 (buena práctica de seguridad en EC2)
  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name = "telsolis-vpn"
  }

  # Si Canonical publica una imagen nueva, no recrear el servidor por eso.
  lifecycle {
    ignore_changes = [ami]
  }
}

# IP pública fija. Existe aunque el servidor esté apagado (encendida = false),
# así el dominio telsolis.tech puede apuntarle sin cambiar en cada sesión.
resource "aws_eip" "vpn" {
  domain = "vpc"

  tags = {
    Name = "telsolis-vpn"
  }
}

resource "aws_eip_association" "vpn" {
  count = var.encendida ? 1 : 0

  instance_id   = aws_instance.vpn[0].id
  allocation_id = aws_eip.vpn.id
}

# Inventario para Ansible, generado con la IP real del servidor.
resource "local_file" "inventario" {
  filename        = "${path.module}/../ansible/inventario.ini"
  file_permission = "0644"
  content = templatefile("${path.module}/inventario.ini.tftpl", {
    ip    = aws_eip.vpn.public_ip
    llave = pathexpand(var.llave_privada)
  })
}
