locals {

  helm_charts = {

    #### NETWORKING BASICS ####

    "traefik" = {
      name       = "traefik"
      repository = "https://helm.traefik.io/traefik"
      chart      = "traefik"
      version    = "37.3.0"
      namespace  = kubernetes_namespace.ns["ingress"].metadata[0].name

      values = [templatefile("${path.module}/yaml/traefik.yaml", {
        dns_zone = var.dns_orb_zone
        })
      ]
    }

    ####

    "external-dns" = {
      name       = "external-dns"
      namespace  = kubernetes_namespace.ns["dns"].metadata[0].name
      repository = "https://kubernetes-sigs.github.io/external-dns/"
      chart      = "external-dns"
      version    = "1.19.0"

      values = [templatefile("${path.module}/yaml/external-dns.yaml", {
        dns_server_name       = "pdns"
        dns_server_address    = "http://pdns.${kubernetes_namespace.ns["dns"].metadata[0].name}.${var.dns_cluster_zone}:${var.dns_server_port}"
        dns_server_password   = var.dns_server_password
        dns_private_zone_name = var.dns_private_zone_name
        })
      ]
    }
    "pdns" = {
      name      = "pdns"
      chart     = "https://github.com/mturnaviotov/k8s-pdns/releases/download/0.0.5/pdns-0.0.5.tgz"
      namespace = kubernetes_namespace.ns["dns"].metadata[0].name
      version   = "0.0.5"
      values = [templatefile("${path.module}/yaml/pdns.yaml", {
        zone_name = var.dns_private_zone_name
        password  = var.dns_server_password
      })]
    }

    ####

    "metallb" = {
      name       = "metallb"
      repository = "https://metallb.github.io/metallb"
      chart      = "metallb"
      namespace  = kubernetes_namespace.ns["metallb-system"].metadata[0].name
      version    = "0.15.3"
    }

    ####

    "cert-manager" = {
      name      = "cert-manager"
      chart     = "oci://quay.io/jetstack/charts/cert-manager"
      namespace = kubernetes_namespace.ns["cert-manager"].metadata[0].name
      version   = "v1.19.1"

      set = [
        {
          name : "prometheus.enabled",
          value : "true"
        },
        {
          name  = "installCRDs"
          value = "true"
        }
      ]
    }

    #### NETWORKING BASICS FINISH ####

    # Vault disabled due to manual installation and Terraform import complexity
    # "vault" = {
    #   name       = "vault"
    #   repository = "https://helm.releases.hashicorp.com"
    #   chart      = "vault"
    #   namespace  = kubernetes_namespace.ns["vault"].metadata[0].name
    #   version    = "0.32.0"

    #   values = [templatefile("${path.module}/yaml/vault.yaml", {
    #     admin_token          = var.vault_admin_token
    #     server               = "vault.${var.dns_private_zone_name}"
    #     kubernetes_namespace = kubernetes_namespace.ns["vault"].metadata[0].name
    #     })
    #   ]
    # }

    #### CI/CD ####
    "jenkins" = {
      name       = var.name_jenkins
      repository = "https://charts.jenkins.io"
      chart      = var.name_jenkins
      namespace  = kubernetes_namespace.ns["jenkins"].metadata[0].name
      version    = "5.9.8"

      values = [templatefile("${path.module}/yaml/jenkins.yaml", {
        admin_password       = var.jenkins_admin_password
        admin_email          = "${var.name_jenkins}@${var.keycloak_realm}"
        dockerhub_login      = var.jenkins_dockerhub_login
        dockerhub_password   = var.jenkins_dockerhub_password
        oidc_secret          = keycloak_openid_client.jenkins.client_secret
        jenkins_admin_group  = "${var.name_jenkins}-admin"
        jenkins_full_url     = "${var.name_jenkins}.${kubernetes_namespace.ns["jenkins"].metadata[0].name}.${var.dns_cluster_zone}"
        jenkins_url          = "${var.name_jenkins}.${var.dns_private_zone_name}"
        kubernetes_namespace = kubernetes_namespace.ns["jenkins"].metadata[0].name
        oidc_issuer          = "${var.name_keycloak}.${var.dns_private_zone_name}/realms/${var.keycloak_realm}"
        oidc_clientid        = var.name_jenkins
        dns_zone             = var.dns_cluster_zone
        github_account       = var.github_account
        github_pat           = var.github_pat
        })
      ]
    }

    ####

    "argocd" = {
      name       = "argocd"
      repository = "https://argoproj.github.io/argo-helm"
      chart      = "argo-cd"
      namespace  = kubernetes_namespace.ns["argocd"].metadata[0].name
      version    = "9.4.12"

      values = [templatefile("${path.module}/yaml/argocd.yaml", {
        clientID           = "argocd"
        oidc_client_secret = keycloak_openid_client.argocd.client_secret
        issuer             = "https://${var.name_keycloak}.${var.dns_private_zone_name}/realms/${var.keycloak_realm}"
        admin_groups       = ["argocd-admin"]
        argo_url           = "argocd.${var.dns_private_zone_name}"
        })
      ]
    }

    #### CI/CD FINISH ####

    #### MONITORING ####

    "alloy" = {
      name       = "alloy"
      repository = "https://grafana.github.io/helm-charts"
      chart      = "alloy"
      namespace  = kubernetes_namespace.ns["mon"].metadata[0].name
      version    = "1.4.0"

      values = [templatefile("${path.module}/yaml/alloy.yaml", {
        loki_url = "https://loki.${var.dns_private_zone_name}"
        })
      ]
    }

    ####

    "loki" = {
      name       = "loki"
      repository = "https://grafana.github.io/helm-charts"
      chart      = "loki"
      namespace  = kubernetes_namespace.ns["mon"].metadata[0].name
      version    = "6.46.0"

      values = [templatefile("${path.module}/yaml/loki.yaml", {})
      ]
    }
    ####

    "kps" = {
      name       = "kps"
      repository = "https://prometheus-community.github.io/helm-charts"
      chart      = "kube-prometheus-stack"
      namespace  = kubernetes_namespace.ns["mon"].metadata[0].name
      version    = "79.5.0"

      values = [templatefile("${path.module}/yaml/kps.yaml", {
        clientID     = "grafana"
        zone_name    = var.dns_private_zone_name
        issuer       = "https://${var.name_keycloak}.${var.dns_private_zone_name}/realms/${var.keycloak_realm}"
        admin_groups = ["grafana-admin"]
      })]
    }

    #### MONITORING FINISHED ####

  }
}

# terraform import example
# terraform import 'module.helm["external-dns"].helm_release.app' dns/external-dns
module "helm" {
  for_each = local.helm_charts

  source = "./modules/helm"

  name          = each.key
  chart         = lookup(each.value, "chart", "")
  repository    = lookup(each.value, "repository", "")
  chart_version = lookup(each.value, "version", "")
  namespace     = each.value.namespace
  values        = lookup(each.value, "values", [])
  set           = lookup(each.value, "set", [])
}
