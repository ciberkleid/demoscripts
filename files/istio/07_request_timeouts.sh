# https://istio.io/docs/tasks/traffic-management/request-timeouts/

# Make sure you are in the bookinfo namespace
kubens bookinfo
# OR: kubectl config set-context $(kubectl config current-context) --namespace=bookinfo

# Re-set bookinfo exercise
kubectl apply -f samples/bookinfo/networking/virtual-service-all-v1.yaml

# Route request to reviews:v2 (uses ratings)
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews
spec:
  hosts:
    - reviews
  http:
  - route:
    - destination:
        host: reviews
        subset: v2
EOF

# Add 2s delay to ratings using the fault delay (as in fault injection exercise)
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ratings
spec:
  hosts:
  - ratings
  http:
  - fault:
      delay:
        percent: 100
        fixedDelay: 2s
    route:
    - destination:
        host: ratings
        subset: v1
EOF

# Check the productpage on the app:
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')

export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
echo $GATEWAY_URL
echo http://$GATEWAY_URL/productpage

# Add half a second request timeout
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews
spec:
  hosts:
  - reviews
  http:
  - route:
    - destination:
        host: reviews
        subset: v2
    timeout: 0.5s
EOF

# Revisit page
echo http://$GATEWAY_URL/productpage

# Note: timeout happens after 1 second, not half second:
# The reason that the response takes 1 second, even though the timeout is configured at half a second,
# is because there is a hard-coded retry in the productpage service, so it calls the timing out reviews
# service twice before returning.

# In addition to overriding them in route rules, as you did in this task, they can also be overridden on
# a per-request basis if the application adds an x-envoy-upstream-rq-timeout-ms header on outbound requests.
# In the header, the timeout is specified in milliseconds instead of seconds.

# Cleanup
kubectl delete -f samples/bookinfo/networking/virtual-service-all-v1.yaml

