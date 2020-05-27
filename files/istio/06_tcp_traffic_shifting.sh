# https://istio.io/docs/tasks/traffic-management/tcp-traffic-shifting/

# Create a namespace for this exercise
kubectl create namespace istio-io-tcp-traffic-shifting

# OPTION 1: Manually inject sidecar during kubectl apply
# The istioctl kube-inject command modifieswill modify the tcp-echo-services.yaml file before creating the deployments
kubectl apply -f <(istioctl kube-inject -f samples/tcp-echo/tcp-echo-services.yaml) -n istio-io-tcp-traffic-shifting

# OPTION 2: Use automatic injection
# kubectl label namespace istio-io-tcp-traffic-shifting istio-injection=enabled
# kubectl apply -f samples/tcp-echo/tcp-echo-services.yaml -n istio-io-tcp-traffic-shifting

# Route all TCP traffic to the v1 version of the tcp-echo microservice
kubectl apply -f samples/tcp-echo/tcp-echo-all-v1.yaml -n istio-io-tcp-traffic-shifting

# Get Ingress HOST and Ingress TCP Port
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="tcp")].port}')

# Send some traffic:
for i in {1..10}; do \
  docker run -e INGRESS_HOST=$INGRESS_HOST -e INGRESS_PORT=$INGRESS_PORT -it --rm busybox sh -c "(date; sleep 1) | nc $INGRESS_HOST $INGRESS_PORT"; \
done

# Confirm the change
kubectl get virtualservice tcp-echo -o yaml -n istio-io-tcp-traffic-shifting

# Transfer 20% traffic to V2
kubectl apply -f samples/tcp-echo/tcp-echo-20-v2.yaml -n istio-io-tcp-traffic-shifting

# Send some more traffic:
for i in {1..10}; do \
  docker run -e INGRESS_HOST=$INGRESS_HOST -e INGRESS_PORT=$INGRESS_PORT -it --rm busybox sh -c "(date; sleep 1) | nc $INGRESS_HOST $INGRESS_PORT"; \
done

# Cleanup
kubectl delete -f samples/tcp-echo/tcp-echo-all-v1.yaml -n istio-io-tcp-traffic-shifting
kubectl delete -f samples/tcp-echo/tcp-echo-services.yaml -n istio-io-tcp-traffic-shifting
kubectl delete namespace istio-io-tcp-traffic-shifting
