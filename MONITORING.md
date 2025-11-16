# TEMPORARY CHEAT SH.T

Assume that we will use mon as k8s monitoring group.
Check and fix values carefully. some of the in default template will fail chat deploy
You can point to this repo small one node basic cluster

## Alloy:

Start point:

'''
curl https://raw.githubusercontent.com/grafana/alloy/main/operations/helm/charts/alloy/values.yaml > alloy-default.yaml
cp alloy-default.yaml alloy.yaml
helm install -n mon alloy grafana/alloy -f alloy.yaml
'''

## Loki

Start point:

'''
curl https://raw.githubusercontent.com/grafana/loki/refs/heads/main/production/helm/loki/values.yaml > loki-default.yaml
cp loki-default.yaml loki.yaml
helm install -n mon loki grafana/loki -f loki.yaml
'''

## Prometheus stack

'''
helm install -n mon  grafana-operator oci://ghcr.io/grafana/helm-charts/grafana-operator --version v5.20.0
helm install -n mon kps prometheus-community/kube-prometheus-stack
'''