# Add a namespace label to instruct Istio to automatically inject Envoy
# sidecar proxies to apps that are deployed later

kubectl create ns bookinfo
kubectl label namespace bookinfo istio-injection=enabled

kubens bookinfo
# OR: kubectl config set-context $(kubectl config current-context) --namespace=bookinfo

# Deploy sample app
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml

# Validate that app is working inside the cluster:
kubectl get pods  # Note 2/2 containers per pod, one is Envoy sidecar
kubectl exec -it $(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}') -c ratings -- curl productpage:9080/productpage | grep -o "<title>.*</title>"; echo

# Create an Istio Ingress Gateway, which map a path to a route at the edge of your mesh
# Associate this application with the Istio gateway
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
kubectl get gateway

export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')

export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
echo $GATEWAY_URL
echo http://$GATEWAY_URL/productpage

curl echo http://$GATEWAY_URL/productpage | grep -o "<title>.*</title>"; echo




