```bash
kubectl get pods -o wide
kubectl get deployments
kubectl get rs
kubectl describe deployments/caddy
kubectl scale deployments/caddy --replicas=10
kubectl delete deployments --all
```

```bash
kubectl create deployment caddy --image=caddy:latest
kubectl expose deployment/caddy --type="NodePort" --port 80
minikube service caddy --url
```

