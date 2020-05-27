# https://istio.io/docs/tasks/traffic-management/request-routing/

# Make sure you ar ein the bookinfo namespace
kubens bookinfo
# OR: kubectl config set-context $(kubectl config current-context) --namespace=bookinfo

# Create default destination rules (no mTLS version)
kubectl apply -f samples/bookinfo/networking/destination-rule-all.yaml

# Display destination rules to make sure they have propagated
kubectl get destinationrules -o yaml

# Create virtual services to v1 subsets
kubectl apply -f samples/bookinfo/networking/virtual-service-all-v1.yaml

# Display the defined routes
kubectl get virtualservices -o yaml

# Display corresponding subset definitions
kubectl get destinationrules -o yaml

# User-based routing (product page adds user info to requests to the reviews app)
kubectl apply -f samples/bookinfo/networking/virtual-service-reviews-test-v2.yaml

# Confirm new rule was created
kubectl get virtualservice reviews -o yaml

# On the /productpage of the Bookinfo app, log in as user jason (open http://$GATEWAY_URL/productpage in a browser)
# Notice the reviews have stars

# Clean up before the next step
kubectl delete -f samples/bookinfo/networking/virtual-service-all-v1.yaml
