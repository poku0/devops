# Task

## Deploy a web application to your Kubernetes cluster using a Deployment with health checks and resource limits, then expose it with a Service. Verify everything works via port-forward.


```bash
kubectl apply -f nginx-deployment.yml
kubectl apply -f nginx-service.yml
kubectl get pods
kubectl get rs
kubectl describe svc nginx-service
kubectl port-forward svc/nginx-service 8080:80
```

```bash
kubectl scale --replicas=5 -f nginx-deployment.yml
```

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl patch deployment metrics-server -n kube-system --type='json' -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
kubectl top pods -A
```

```bash
kubectl describe pods nginx-app-7f5f755fd8-5zjjw | grep -E 'Liveness|Readiness' 
```

```bash
kubectl delete pods nginx-app-7f5f755fd8-6hjrx
kubectl get pods
```
