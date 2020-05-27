# https://istio.io/docs/tasks/traffic-management/traffic-shifting

# Make sure you ar ein the bookinfo namespace
kubens bookinfo
# OR: kubectl config set-context $(kubectl config current-context) --namespace=bookinfo

# Route all traffic to the v1 version of each microservice.
kubectl apply -f samples/bookinfo/networking/virtual-service-all-v1.yaml

# Test app - all traffic goes to reviews:v1, which does not include star ratings (no stars appear)

# Transfer 50% of traffic to reviews:v3
kubectl apply -f samples/bookinfo/networking/virtual-service-reviews-50-v3.yaml

# Confirm:
kubectl get virtualservice reviews -o yaml

# Check service - see starts 50% of time

# Move all traffic to reviews:v3
kubectl apply -f samples/bookinfo/networking/virtual-service-reviews-v3.yaml

# Cleanup before next step
kubectl delete -f samples/bookinfo/networking/virtual-service-all-v1.yaml