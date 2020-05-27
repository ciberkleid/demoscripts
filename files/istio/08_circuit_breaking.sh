# https://istio.io/docs/tasks/traffic-management/circuit-breaking/

kubectl create ns istio-httpbin-example

kubens istio-httpbin-example
# OR: kubectl config set-context $(kubectl config current-context) --namespace=istio-httpbin-example

# Deploy example
# OPTION 1, automatic sidecar injection:
kubectl label namespace istio-httpbin-example istio-injection=enabled
kubectl apply -f samples/httpbin/httpbin.yaml

# OPTION 2, manual sidecar injection
# kubectl apply -f <(istioctl kube-inject -f samples/httpbin/httpbin.yaml)

# Create a destination rule to apply circuit breaking settings when calling the httpbin service:
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: httpbin
spec:
  host: httpbin
  trafficPolicy:
    connectionPool:
      tcp:
        maxConnections: 1
      http:
        http1MaxPendingRequests: 1
        maxRequestsPerConnection: 1
    outlierDetection:
      consecutiveErrors: 1
      interval: 1s
      baseEjectionTime: 3m
      maxEjectionPercent: 100
EOF

# Validate destination rule
kubectl get destinationrule httpbin -o yaml

# Add fortio (load testing) client. Inject it with sidecar proxy
kubectl apply -f samples/httpbin/sample-client/fortio-deploy.yaml
# If manually injecting sidecars:
#kubectl apply -f <(istioctl kube-inject -f samples/httpbin/sample-client/fortio-deploy.yaml)

# Log in to the client pod and use the fortio tool to call httpbin. Pass in -curl to indicate that you just want to make one call
FORTIO_POD=$(kubectl get pod | grep fortio | awk '{ print $1 }')
kubectl exec -it $FORTIO_POD  -c fortio /usr/bin/fortio -- load -curl http://httpbin:8000/get

# Should get "200 OK"

# Call the service with two concurrent connections (-c 2) and send 20 requests (-n 20)
kubectl exec -it $FORTIO_POD  -c fortio /usr/bin/fortio -- load -c 2 -qps 0 -n 20 -loglevel Warning http://httpbin:8000/get

# Look for something like this in the output:
# Code 200 : 16 (80.0 %)
# Code 503 : 4 (20.0 %)
# NOTE: Many requests made were successful because the istio-proxy allows for some leeway

# Try three concurrent connections
kubectl exec -it $FORTIO_POD  -c fortio /usr/bin/fortio -- load -c 3 -qps 0 -n 30 -loglevel Warning http://httpbin:8000/get
# Code 200 : 10 (33.3 %)
# Code 503 : 20 (66.7 %)
# NOTE: Now you start to see the expected circuit breaking behavior. Only 36.7% of the requests succeeded and the rest were trapped by circuit breaking

# Query the istio-proxy stats to see more:
kubectl exec $FORTIO_POD -c istio-proxy -- pilot-agent request GET stats | grep httpbin | grep pending
# Excerpt:
# cluster.outbound|8000||httpbin.istio-httpbin-example.svc.cluster.local.upstream_rq_pending_overflow: 38
# cluster.outbound|8000||httpbin.istio-httpbin-example.svc.cluster.local.upstream_rq_pending_total: 43

# NOTE: upstream_rq_pending_overflow value shows how many have been flagged for circuit breaking

# Remove the rules
kubectl delete destinationrule httpbin

# Cleanup
kubectl delete deploy httpbin fortio-deploy
kubectl delete svc httpbin fortio
kubectl delete ns istio-httpbin-example



