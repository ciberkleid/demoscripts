# https://istio.io/docs/tasks/traffic-management/fault-injection/

# Make sure you ar ein the bookinfo namespace
kubens bookinfo
# OR: kubectl config set-context $(kubectl config current-context) --namespace=bookinfo

# Re-run these commands from previous step:
kubectl apply -f samples/bookinfo/networking/virtual-service-all-v1.yaml
kubectl apply -f samples/bookinfo/networking/virtual-service-reviews-test-v2.yaml

# Create a fault injection rule to delay traffic coming from the test user jason.
kubectl apply -f samples/bookinfo/networking/virtual-service-ratings-test-delay.yaml

# Re-test app as jason user. Expect to get page load after 7s and "Error fetching product reviews"
# Page actually loaded in about 6 seconds (check with browser "Developer Tools", reload page to see timeout)

# Create a fault injection rule to send an HTTP abort for user jason
# Expect the page to load immediately and display the Ratings service is currently unavailable message
kubectl apply -f samples/bookinfo/networking/virtual-service-ratings-test-abort.yaml

# Cleanup before next step
kubectl delete -f samples/bookinfo/networking/virtual-service-all-v1.yaml




