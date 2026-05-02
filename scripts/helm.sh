# Add the repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update


helm install prometheus prometheus-community/kube-prometheus-stack \
  -n monitoring \
  --set grafana.adminPassword=admin \
  --set prometheus.prometheusSpec.resources.requests.memory=1Gi \
  --set prometheus.prometheusSpec.resources.limits.memory=2Gi



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




helm install logstash elastic/logstash \
  -n monitoring \
  --set persistence.enabled=false \
  --set resources.requests.cpu="100m" \
  --set resources.requests.memory="512Mi" \
  --set resources.limits.memory="1Gi" \
  --set logstashConfig."logstash\.yml"="http.host: 0.0.0.0\nxpack.monitoring.enabled: false" \
  --set logstashPipeline."logstash\.conf"="
    input {
      beats {
        port => 5044
      }
    }
    filter {
      if [kubernetes][container][name] == 'log-generator' {
        mutate { add_tag => ['learning_logstash'] }
      }
    }
    output {
      elasticsearch {
        hosts => ['http://elasticsearch-master:9200']
        index => 'logstash-%{+YYYY.MM.dd}'
      }
    }"


helm install filebeat elastic/filebeat \
  -n monitoring \
  --set daemonset.resources.requests.cpu="100m" \
  --set daemonset.resources.requests.memory="100Mi"


helm install my-log-gen . -n monitoring

helm upgrade my-log-gen . -n monitoring -f log-gen-override.yaml
kubectl rollout restart deployment/my-log-gen-log-generator -n monitoring
