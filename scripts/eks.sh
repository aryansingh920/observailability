# 1. Watch all containers come up.
kubectl get pods --namespace=monitoring -l release=kibana -w
# 2. Retrieve the elastic user's password.
kubectl get secrets --namespace=monitoring elasticsearch-master-credentials -ojsonpath='{.data.password}' | base64 -d
# 3. Retrieve the kibana service account token.
kubectl get secrets --namespace=monitoring kibana-kibana-es-token -ojsonpath='{.data.token}' | base64 -d
