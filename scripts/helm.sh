# Add the repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update


helm install obs prometheus-community/kube-prometheus-stack -n monitoring



# Uninstall the failed release (if it exists in the history)
helm uninstall kibana -n monitoring


helm list -n monitoring   

# Delete the Helm releases
helm uninstall elasticsearch -n monitoring 2>/dev/null
helm uninstall kibana -n monitoring 2>/dev/null

# Force delete any stuck pods or jobs
kubectl delete jobs,pods,secrets -n monitoring -l release=elasticsearch
kubectl delete jobs,pods,secrets -n monitoring -l release=kibana



helm install elasticsearch elastic/elasticsearch \
  -n monitoring \
  --set replicas=1 \
  --set minimumMasterNodes=1 \
  --set resources.requests.cpu="100m" \
  --set resources.requests.memory="1Gi" \
  --set resources.limits.memory="2Gi" \
  --set esJavaOpts="-Xmx512m -Xms512m"

  helm install kibana elastic/kibana \
  -n monitoring \
  --set replicas=1 \
  --set resources.requests.cpu="100m" \
  --set resources.requests.memory="512Mi" \
  --set resources.limits.memory="1Gi" \
  --set preInstallJob.enabled=false

kubectl port-forward deployment/kibana-kibana 5601:5601 -n monitoring


