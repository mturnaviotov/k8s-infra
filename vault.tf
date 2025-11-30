resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"

  tune {
    token_type         = "default-service"
    max_lease_ttl      = "768h"
    listing_visibility = "unauth"
  }
}

resource "vault_kubernetes_auth_backend_config" "kubernetes" {
  backend                = vault_auth_backend.kubernetes.path
  kubernetes_host        = "https://kubernetes.default.svc.cluster.local"
  issuer                 = "https://kubernetes.default.svc.cluster.local"
  disable_iss_validation = "true"
}

resource "vault_kubernetes_auth_backend_role" "myapp" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "myapp"
  bound_service_account_names      = ["*"]
  bound_service_account_namespaces = ["*"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.cluster.name]
  audience                         = "https://kubernetes.default.svc.cluster.local"
}


resource "vault_policy" "cluster" {
  name = "cluster"

  # ! Allow read access to the secret at secret/data/cluster/py/db,
  # ! /data is required for KV v2 for reading secrets from injectors
  policy = <<EOT
    path "secret/data/cluster/py/db" {
        capabilities = ["read"]
    }
    EOT
}

resource "vault_generic_secret" "myapp" {
  path      = "secret/cluster/py/db"
  data_json = <<EOT
    {
        "username":   "${var.db_username}",
        "password":   "${var.db_password}"
    }
    EOT
}
