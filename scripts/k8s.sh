kind create cluster --config kind-config.yaml --name dev-cluster
docker exec dev-cluster-control-plane sysctl -w vm.max_map_count=262144


# Install into a dedicated namespace
kubectl create namespace monitoring


kubectl get pods -A


# Delete the stuck job
kubectl delete job pre-install-kibana-kibana -n monitoring


