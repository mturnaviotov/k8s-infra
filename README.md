# Intro

Here i will collect all Kubernetes related basic CI/CD stuff, like
Networks, DNS, monitoring, CI/CD for providing whole Infrastructure as a code

# Components

- [x] Traefik       (Ingress)
- [x] ExternalDNS   (DNS)
- [x] PowerDNS      (DNS)
- [x] Cert Manager  (SSL)
- [x] K8S Dashboard (UI)
- [x] KeyCloak      (AAA)
- [x] Jenkins       (CI/CD)
- [x] ArgoCD        (CD)
- [x] Test ToDo Application deployed via ArgoCD (CD)

# TODO:

1. Link all services to KeyCloak as main user database
2. Add Nexus as Docker image and helm registry

## Notices

1. You should build all images locally for you before use - PowerDNS, ToDo, etc.
2. ArgoCD Cluster will be in UNKNOWN state until first deploy
