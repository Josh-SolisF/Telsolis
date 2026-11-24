# Fase 4: VPN con IaC (Terraform + Ansible)

Servidor OpenVPN en AWS. Computadora por **TAP/TCP 1194**, teléfono por **TUN/TCP 1195**
(Android/iOS no soportan TAP; autorizado por el profesor).

| Carpeta | Herramienta | Qué hace |
|---|---|---|
| `terraform/` | Terraform | EC2 Ubuntu 24.04, security group, llave SSH, IP fija; genera `ansible/inventario.ini` |
| `ansible/` | Ansible | OpenVPN (2 instancias), PKI con easy-rsa, reenvío + NAT, perfiles `.ovpn` en `ansible/clientes/` |

Se ejecuta desde la VM `docker`. Requisitos: `terraform`, `aws` (CLI), `ansible`,
llave `~/.ssh/telsolis-aws` y credenciales en `aws configure` (fuera del repo).

```bash
cd paas/vpn/terraform
terraform init
terraform apply                        # crea todo
cd ../ansible
ansible-playbook vpn.yml               # configura OpenVPN y genera los perfiles

# Apagar entre sesiones sin perder la IP fija (el DNS del dominio sigue válido):
terraform -chdir=../terraform apply -var encendida=false
# Borrar absolutamente todo (al terminar el examen):
terraform -chdir=../terraform destroy
```

No van al repositorio: `*.tfstate`, `.terraform/`, `ansible/inventario.ini`, `ansible/clientes/` (llaves privadas).
