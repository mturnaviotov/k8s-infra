# Intro

Here i will collect all Kubernetes related basic CI/CD stuff, like
Networks, DNS, monitoring, CI/CD for providing whole Infrastructure as a code

# Components
## Network basics
  - [x] Traefik       (Ingress)
  - [x] ExternalDNS   (DNS)
  - [x] PowerDNS      (DNS)
  - [x] Cert Manager  (SSL)
  - [x] K8S Dashboard (UI)
## AAA
- [x] KeyCloak      (AAA)   - installation via quick start script (kubectl apply -f...)
- [x] Vault                 - Secrets manager
## CI/CD
- [x] Jenkins       (CI/CD) - SSO
- [x] ArgoCD        (CD)    - SSO
## Monitoring
- [x] Alloy + Loki + Prometheus + Grafana (SSO)
## Applications
- [x] Test ToDo Application deployed via ArgoCD (CD)

# Installation

Due to external CRD absense you can't install Helm chart and dependent resources at the same time, 
You need to firstly install by renaming all non used in this terraform apply cycle TF files to avoid fail, and add it later in next 'terraform apply' cycle

Please carefully read TF files, they contains pre installation steps, like certificates generation for cert-manager

## How to install

- Copy terraform.tfvars.default to terraform.tfvars
- Edit it properly
- Check headers of yaml/keycloak.yaml, you need to install it manually before terraform will succesfully run
  `kubectl -n auth apply -f yaml/keycloak.yaml`
- Sign in to keycloak, go to clients -> admin-cli, enable client authentication, go to credentials
  tab and copy client secret to terraform.vars
- Generate certificates and add it to trusted sources via you system way.
  ```
  openssl req -x509 -newkey rsa:4096 -keyout ca.key -out ca.crt -days 365 -nodes -subj "/CN=local-ca"
  # Then install the CA cert into your system trust store, e.g. on macOS:
  sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ca.crt
  ```
- My way with OrbStack - disable 'second' wave started from 9_* and comment Vault provider in
  providers.tf, and apply first
  ```
  for i in `ls 9_*`; do mv "$i" "$i.prepared" ; done
  terraform apply --auto-approve
  ```
- Wait for time out for Argo and Jenkins, uncomment Vault and second wave, apply again
  ```
  for i in `ls *.prepared`; do mv "$i" `echo $i | sed -e 's/.prepared$//g'` ; done
  terraform import 'kubernetes_namespace.ns["auth"]' auth
  terraform import 'module.helm["argocd"].helm_release.app' argocd/argocd
  terraform import 'module.helm["jenkins"].helm_release.app' jenkins/jenkins
  terraform apply --auto-approve
  ```
- Update /etc/resolver/zone.internal for proper PowerDNS Ingress/MetalLB IP and update MacOS
  resolver zone
  ```
  dnsPod=`kubectl get svc --all-namespaces | grep pdns | awk '{print $5}'`
  sudo echo -e "nameserver $dnsPod\nport 53" > /etc/resolver/zone.internal
  sudo killall -HUP mDNSResponder
  ```

# TODO:

1. Add Nexus as Docker image and helm registry (Now used DockerHub and GitHub artifacts for Helm charts)

## Notices

1. ArgoCD Cluster will be in UNKNOWN state until first deploy
