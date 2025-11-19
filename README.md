# Intro

Here i will collect all Kubernetes related basic CI/CD stuff, like
Networks, DNS, monitoring, CI/CD for providing whole Infrastructure as a code

# Components

- [x] Traefik       (Ingress)
- [x] ExternalDNS   (DNS)
- [x] PowerDNS      (DNS)
- [x] Cert Manager  (SSL)
- [x] K8S Dashboard (UI)
- [x] KeyCloak      (AAA)   - installation via quick start script (kubectl apply -f...)
- [x] Jenkins       (CI/CD) - SSO
- [x] ArgoCD        (CD)    - SSO
- [x] Test ToDo Application deployed via ArgoCD (CD)
- [x] Alloy + Loki + Prometheus + Grafana (SSO)

# Installation

Due to external CRD absense you can't install Helm chart and dependent resources at the same time, 
You need to firstly install by renaming all non used in this terraform apply cycle TF files to avoid fail, and add it later in next 'terraform apply' cycle

Please carefully read TF files, they contains pre installation steps, like certificates generation for cert-manager

0. Traefik, Dashboard, cert-manager, dns-external and PowerDNS
1. KeyCloak
2. Jenkins, ArgoCD
3. ArgoCD Application
4. Ingresses
5. Monitoring

# TODO:

1. Add Nexus as Docker image and helm registry (Now used DockerHub and GitHub artifacts for Helm charts)

## Notices

1. ArgoCD Cluster will be in UNKNOWN state until first deploy
