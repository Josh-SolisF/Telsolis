# Fase 6: CMS con Kubernetes

WordPress publicado en **k3s** (VM `k8s`, 192.168.56.13) en `http://cms.telsolis.test`.
Su base de datos es el **MySQL en Docker Compose** de la VM `docker` (`paas/docker-compose/06-mysql`):
el CMS y la BD están en servidores distintos.

```
navegador → cms.telsolis.test (192.168.56.13:80) → Ingress (Traefik) → Service → pods de WordPress
                                                                         ↓ 3306
                                                     VM docker: MySQL (wordpress_k8s, usuario wpk8s)
```

| Archivo | Recurso |
|---|---|
| `00-namespace.yaml` | Namespace `telsolis-cms` |
| `01-pvc.yaml` | Volumen persistente (local-path) para `/var/www/html` |
| `02-deployment.yaml` | Deployment de WordPress (réplicas, probes, límites) |
| `03-service.yaml` | Service interno |
| `04-ingress.yaml` | Ingress para `cms.telsolis.test` |

## Instalación

```bash
# k3s (una vez) en la VM k8s
curl -sfL https://get.k3s.io | sh -s - --node-ip 192.168.56.13 --flannel-iface enp0s8 --write-kubeconfig-mode 644

# Secret con la contraseña de la BD (WPK8S_PASSWORD de paas/docker-compose/06-mysql/.env); no va al repo
kubectl create namespace telsolis-cms
kubectl -n telsolis-cms create secret generic wordpress-db --from-literal=password='CONTRASEÑA'

# Todo lo demás
kubectl apply -k .
```

## Demo

```bash
kubectl -n telsolis-cms get all,pvc,ingress
kubectl -n telsolis-cms scale deployment wordpress --replicas=2     # escalar
kubectl -n telsolis-cms delete pod -l app=wordpress --wait=false     # autorreparación
kubectl -n telsolis-cms get pods -w
```
