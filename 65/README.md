# Task

## Helm.

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm search repo bitnami
helm repo update
helm install bitnami/mysql --generate-name
helm show chart bitnami/mysql
helm show all bitnami/mysql
helm list 
helm status mysql-1774376022
helm uninstall mysql-1774376022
```

```bash
helm upgrade --install happy-panda bitnami/wordpress -f values.yaml
```