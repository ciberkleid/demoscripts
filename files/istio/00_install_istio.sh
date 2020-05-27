# https://github.com/istio/istio/releases

# Set ISTIO_VERSION to latest version of Istio
export ISTIO_VERSION=`curl -L -s https://api.github.com/repos/istio/istio/releases | grep tag_name | sed "s/ *\"tag_name\": *\"\\(.*\\)\",*/\\1/" | grep -v -E "(alpha|beta|rc)\.[0-9]$" | sort -t"." -k 1,1 -k 2,2 -k 3,3 -k 4,4 | tail -n 1`

# Install Istio
curl -L https://git.io/getLatestIstio | sh -
cd istio-${ISTIO_VERSION}
cp bin/istioctl ~/opt

# Use demo profile
istioctl manifest apply --set profile=demo

# See what was installed
kubectl get all -n istio-system
kubectl api-resources | grep istio

# Add a namespace label to instruct Istio to automatically inject Envoy
# sidecar proxies to apps that are deployed later
#kubectl label namespace default istio-injection=enabled
# Disable with:
#kubectl label namespace default istio-injection=disabled --overwrite

# Validate that a load balancer was created
k get svc istio-ingressgateway -n istio-system
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
gcloud compute forwarding-rules list --filter=IP_ADDRESS:${INGRESS_HOST}


