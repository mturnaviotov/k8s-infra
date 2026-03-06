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

This is a pre-requsites for succesfull deployment for Terraform, so we will install it manually

AAA - Authentication, Authorization, Accounting

SSO - Single point of user management

- [x] KeyCloak      (AAA)   - installation via quick start script (kubectl apply -f...)
- [x] Vault                 - Secrets manager, installed via Helm

## CI/CD

- [x] Jenkins       (CI/CD) - SSO used
- [x] ArgoCD        (CD)    - SSO used

## Monitoring

- [x] Alloy + Loki + Prometheus + Grafana (SSO)

## Applications

- [x] Test ToDo Application deployed via ArgoCD (CD)

# Installation

Due to external CRD absense you can't install Helm chart and dependent resources at the same time, via the Terraform.
You need to firstly install manually external CRD, KeyCloak and Vault before apply Terraform to avoid fail.

Please carefully read TF files, they contains pre installation steps, like certificates generation for cert-manager

## How to install

- Copy terraform.tfvars.default to terraform.tfvars

- Edit it properly

- Check headers of yaml/keycloak.yaml, you need to install it manually before terraform will succesfully run. You also SHOULD change admin password to something more secure in KC_BOOTSTRAP_ADMIN_PASSWORD variable as this service will be used for SSO and have public access
  `kubectl -n auth apply -f yaml/keycloak.yaml`

- Sign in to keycloak, go to clients -> admin-cli, enable client authentication, go to credentials
  tab and copy client secret to terraform.vars

- Update yaml/vault.yaml also for your needs. and Install Vault as prerequirement for terraform

  ```
  helm repo add hashicorp https://helm.releases.hashicorp.com
  helm repo update
  helm install -n vault vault hashicorp/vault -f yaml/vault.yaml --create-namespace
  ```

- Generate certificates and add it to trusted sources via your system way (MacOS example).

  ```
  openssl req -x509 -newkey rsa:4096 -keyout ca.key -out ca.crt -days 365 -nodes -subj "/CN=local-ca"
  # Then install the CA cert into your system trust store, e.g. on macOS:
  sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ca.crt
  ```

- Apply external CRDs due to helm charts fail on first install

  ```
  kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v3.6/docs/content/reference/dynamic-configuration/kubernetes-crd-definition-v1.yml
  kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v3.6/docs/content/reference/dynamic-configuration/kubernetes-crd-rbac.yml
  kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.19.2/cert-manager.crds.yaml
  kubectl apply -k https://github.com/argoproj/argo-cd/manifests/crds\?ref\=stable
  ```

- Import already done namespaces and apply Terraform

  ```
  terraform import 'kubernetes_namespace.ns["auth"]' auth
  terraform import 'kubernetes_namespace.ns["vault"]' vault
  terraform apply --auto-approve
  ```

- Update /etc/resolver/zone.internal for proper PowerDNS Ingress/MetalLB IP and update MacOS
  resolver zone

  ```
  dnsPod=`kubectl get svc --all-namespaces | grep pdns | awk '{print $4}'`
  sudo echo -e "nameserver $dnsPod\nport 53" > /etc/resolver/zone.internal
  sudo killall -HUP mDNSResponder
  ```

# TODO

1. Add Nexus as Docker image and helm registry (Now used DockerHub and GitHub artifacts for Helm charts)

## Notices

1. ArgoCD Cluster will be in UNKNOWN state until first deploy
