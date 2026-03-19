# K8s Infra CI/CD Intro

Here i will collect all Kubernetes related basic CI/CD stuff, like
Networks, DNS, monitoring, CI/CD for providing whole Infrastructure as a code

## Components

### Network basics

- [x] Traefik       (Ingress)
- [x] ExternalDNS   (DNS)
- [x] PowerDNS      (DNS)
- [x] Cert Manager  (SSL)

_-NOTICE-_: For bare metal K8S you need to install CNI (Calico, Cilium, etc.) and MetalLB for IP address management into cluster before applying terraform. For virtual local K3s, OrbStack, etc usually CNI is already included

### AAA

This is a pre-requsites for succesfull deployment for Terraform, so we will install it manually

AAA - Authentication, Authorization, Accounting

SSO - Single point of user management

- [x] KeyCloak      (AAA)   - installation via quick start script (kubectl apply -f...)
- [x] Vault                 - Secrets manager, installed via Helm

### CI/CD

- [x] Jenkins       (CI/CD) - SSO used
- [x] ArgoCD        (CD)    - SSO used

### Monitoring

- [x] Alloy + Loki + Prometheus + Grafana (SSO)

### Applications

- [x] Test ToDo Application deployed via ArgoCD (CD)

## Installation

Due to external CRD absense you can't install Helm chart and dependent resources at the same time via the Terraform.
You need to firstly install manually external CRD, KeyCloak and Vault before apply Terraform to avoid fail.

Please carefully read TF files, they contains pre installation steps, like certificates generation for cert-manager

### How to install

- Copy terraform.tfvars.default to terraform.tfvars

- Edit it properly

- Check headers of yaml/keycloak.yaml, you need to install it manually before terraform will succesfully run. You also SHOULD change admin password to something more secure in KC_BOOTSTRAP_ADMIN_PASSWORD variable as this service will be used for SSO and have public access
  `kubectl -n auth apply -f yaml/keycloak.yaml`

- Sign in to keycloak, go to clients -> admin-cli, enable client authentication, save, go to credentials
  tab and copy client secret to terraform.vars
  _-NOTICE-_: In Terraform KeyCloak installation password changed to random string.

- Update yaml/vault.yaml also for your needs. and Install Vault as prerequirement for terraform
  _-NOTICE-_: In Terraform Vault installation you need manually unseal Vault after installation.
  _-NOTICE-_: In this installation we changed Vault to dev mode and pre-configured root token

  ```bash
  helm repo add hashicorp https://helm.releases.hashicorp.com
  helm repo update
  helm install -n vault vault hashicorp/vault -f yaml/vault.yaml --create-namespace
  ```

- Generate certificates and add it to trusted sources via your system way (MacOS example).

  ```bash
  openssl req -x509 -newkey rsa:4096 -keyout ca.key -out ca.crt -days 365 -nodes -subj "/CN=local-ca"
  # Then install the CA cert into your system trust store, e.g. on macOS:
  sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ca.crt
  ```

- Apply external CRDs due to helm charts fail on first install

  ```bash
  kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v3.6/docs/content/reference/dynamic-configuration/kubernetes-crd-definition-v1.yml
  kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v3.6/docs/content/reference/dynamic-configuration/kubernetes-crd-rbac.yml
  kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.19.2/cert-manager.crds.yaml
  kubectl apply --server-side -f https://github.com/argoproj/argo-cd/manifests/crds\?ref\=stable
  ```

- Import already done namespaces and apply Terraform

  ```bash
  terraform import 'kubernetes_namespace.ns["auth"]' auth
  terraform import 'kubernetes_namespace.ns["vault"]' vault
  terraform apply --auto-approve
  ```

- Enable DNS in your system:

  - MacOS: Update /etc/resolver/zone.internal for proper PowerDNS Ingress/MetalLB IP and update MacOS resolver zone (some operations may be prohibited via sudo and copy paste, so run it via sudo manually)

  ```bash
  dnsPod=`kubectl get svc --all-namespaces | grep pdns | awk '{print $4}'`
  sudo mkdir /etc/resolver/
  sudo echo -e "nameserver $dnsPod\nport 53" > /etc/resolver/zone.internal
  sudo killall -HUP mDNSResponder
  ```

  - Linux: Add to /etc/systemd/resolved.conf and restart service ```sudo systemctl restart systemd-resolved```.

    You can also define your PowerDNS pod here to directly use your private DNS zone

    ```bash
    DNS=10.96.0.10 8.8.8.8 2001:4860:4860::8888
    Domains=~svc.cluster.local ~.
    ```

## TODO

1. Add Nexus as Docker image and helm registry (Now used DockerHub and GitHub artifacts for Helm charts)

### Notices

1. ArgoCD Cluster will be in UNKNOWN state until first deploy.
2. VS Code after updating may fail to connect to your K8s, check Settings - Privacy - Local networking - VS code -> Allow.
3. After MacOS updates may clear your private dns resolvers, if someting goes wrong - check it.

### MULTIPLE INFRASTRUCTURE

You can use custom variables file with custom state file when you have OrbStack and K8s cluster on AWS both at the same time.

```bash
terraform apply -var-file=terraform-aws.tfvars -state=terraform-aws.tfstate # --auto-approve
terraform apply -var-file=terraform-orb.tfvars -state=terraform-orb.tfstate # --auto-approve
```
