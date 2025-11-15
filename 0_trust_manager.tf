# # terraform import kubernetes_manifest.local_ca_bundle 'apiVersion=trust.cert-manager.io/v1alpha1,kind=Bundle,name=local-ca-bundle'
# resource "kubernetes_manifest" "local_ca_bundle" {
#   manifest = {
#     apiVersion = "trust.cert-manager.io/v1alpha1"
#     kind       = "Bundle"
#     metadata = {
#       name = "local-ca-bundle"
#       #namespace = "cert-manager"
#     }
#     spec = {
#       sources = [
#         {
#           useDefaultCAs = true
#         },
#         {
#           secret = {
#             name = "local-ca-key-pair"
#             key  = "tls.crt"
#           }
#         }
#       ]
#       target = {
#         configMap = {
#           key = "trust-bundle.pem"
#         }
#       }
#     }
#   }
# }
