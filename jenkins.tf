# Terraform manifest: jenkins.tf

#########################
# Variables
#########################

# Doesn't work with OIDC auth plugin
variable "jenkins_admin_password" {
  description = "Jenkins admin password"
  default     = "admin"
  type        = string
}

variable "name_jenkins" {
  description = "Name for referencing service"
  default     = "jenkins"
  type        = string
}

# KeyCloak secrets for Jenkins OIDC client
variable "jenkins_keycloak_secret" {
  description = "Jenkins secret from client id"
  default     = "jenkins-keycloak-secret"
  type        = string
  sensitive   = true
}

variable "jenkins_keycloak_clientid" {
  description = "Jenkins client id in Keycloak"
  default     = "jenkins"
  type        = string
  sensitive   = true
}

# DockerHub credentials for Jenkins
variable "jenkins_dockerhub_login" {
  description = "DockerHub login/account for images push"
  default     = "dockerhub-login"
  type        = string
  sensitive   = true
}

variable "jenkins_dockerhub_password" {
  description = "DockerHub password for images push"
  default     = "dockerhub-password"
  type        = string
  sensitive   = true
}

#########################
# Namespaces
#########################

# terraform import kubernetes_namespace.jenkins jenkins
resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = "jenkins"
  }
}

#########################
# Jenkins Helm Chart
#########################

# terraform import helm_release.jenkins jenkins/jenkins
resource "helm_release" "jenkins" {
  name             = var.name_jenkins
  repository       = "https://charts.jenkins.io"
  chart            = var.name_jenkins
  namespace        = kubernetes_namespace.jenkins.metadata[0].name
  create_namespace = false

  values = [<<EOF
controller:
  admin:
    password: "${var.jenkins_admin_password}"

  serviceType: "ClusterIP"

  installPlugins:
    - kubernetes:4384.v1b_6367f393d9
    - workflow-aggregator:608.v67378e9d3db_1
    - git:5.8.0
    - configuration-as-code:2006.v001a_2ca_6b_574
    - oic-auth:4.609.v9de140f63d01
    - role-strategy

  JCasC:
    defaultConfig: false
    configScripts:
      data: |
        credentials:
          system:
            domainCredentials:
            - credentials:
              - usernamePassword:
                  description: "my docker hub account"
                  id: "dockerhub"
                  password: "${var.jenkins_dockerhub_password}"
                  scope: GLOBAL
                  username: "${var.jenkins_dockerhub_login}"
        jenkins:
          authorizationStrategy:
            globalMatrix:
              entries:
              - group:
                  name: "admin"
                  permissions:
                  - "Overall/Administer"
              - group:
                  name: "authenticated"
                  permissions:
                  - "Overall/Read"
                  - "Overall/Administer"  
              - group:
                  name: "jenkins_admin"
                  permissions:
                  - "Overall/Administer"
          clouds:
          - kubernetes:
              containerCap: 10
              containerCapStr: "10"
              jenkinsTunnel: "jenkins-agent.${kubernetes_namespace.jenkins.metadata[0].name}.${var.dns_cluster_zone}:50000"
              jenkinsUrl: "http://${var.name_jenkins}.${kubernetes_namespace.jenkins.metadata[0].name}.${var.dns_cluster_zone}:8080"
              name: "kubernetes"
              namespace: "${kubernetes_namespace.jenkins.metadata[0].name}"
              podLabels:
              - key: "jenkins/jenkins-jenkins-agent"
                value: "true"
              serverUrl: "https://kubernetes.default"
              templates:
              - containers:
                - args: "^$${computer.jnlpmac} ^$${computer.name}"
                  envVars:
                  - envVar:
                      key: "JENKINS_URL"
                      value: "http://${var.name_jenkins}.${kubernetes_namespace.jenkins.metadata[0].name}.${var.dns_cluster_zone}:8080/"
                  image: "jenkins/inbound-agent:3345.v03dee9b_f88fc-5"
                  name: "jnlp"
                  resourceLimitCpu: "512m"
                  resourceLimitMemory: "512Mi"
                  resourceRequestCpu: "512m"
                  resourceRequestMemory: "512Mi"
                  workingDir: "/home/jenkins/agent"
                id: "f60e51047648982e11c2ad5e7d6e2b363e709301fbf1ac2900f37a600a87528a"
                label: "jenkins-jenkins-agent"
                name: "default"
                namespace: "jenkins"
                nodeUsageMode: "NORMAL"
                podRetention: "never"
                serviceAccount: "default"
                slaveConnectTimeout: 100
                slaveConnectTimeoutStr: "100"
                yamlMergeStrategy: "override"
          crumbIssuer:
            standard:
              excludeClientIPFromCrumb: true
          disableRememberMe: false
          disabledAdministrativeMonitors:
          - "hudson.util.DoubleLaunchChecker"
          - "hudson.diagnosis.ReverseProxySetupMonitor"
          labelAtoms:
          - name: "built-in"
          - name: "jenkins-jenkins-agent"
          log: {}
          markupFormatter: "plainText"
          mode: NORMAL
          nodeMonitors:
          - "architecture"
          - "clock"
          - diskSpace:
              freeSpaceThreshold: "1GiB"
              freeSpaceWarningThreshold: "2GiB"
          - "swapSpace"
          - tmpSpace:
              freeSpaceThreshold: "1GiB"
              freeSpaceWarningThreshold: "2GiB"
          - "responseTime"
          numExecutors: 0
          primaryView:
            all:
              name: "all"
          projectNamingStrategy: "standard"
          quietPeriod: 5
          remotingSecurity:
            enabled: true
          scmCheckoutRetryCount: 0
          securityRealm:
            oic:
              clientId: "${var.jenkins_keycloak_clientid}"
              clientSecret: "${var.jenkins_keycloak_secret}"
              disableSslVerification: true
              emailFieldName: "email"
              fullNameFieldName: "firstName LastName"
              groupIdStrategy: "caseInsensitive"
              logoutFromOpenidProvider: false
              serverConfiguration:
                wellKnown:
                  scopesOverride: "openid email profile"
                  wellKnownOpenIDConfigurationUrl: "https://${var.name_keycloak}.${var.dns_private_zone_name}/realms/${var.keycloak_realm}/.well-known/openid-configuration"
              userIdStrategy: "caseInsensitive"
              userNameField: "preferred_username"
          slaveAgentPort: 50000
          updateCenter:
            sites:
            - id: "default"
              url: "https://updates.jenkins.io/update-center.json"
          views:
          - all:
              name: "all"
          viewsTabBar: "standard"
        globalCredentialsConfiguration:
          configuration:
            providerFilter: "none"
            typeFilter: "none"
        appearance:
          consoleUrlProvider: {}
          prism:
            theme: PRISM
        security:
          apiToken:
            creationOfLegacyTokenEnabled: false
            tokenGenerationOnCreationEnabled: false
            usageStatisticsEnabled: true
          cps:
            hideSandbox: false
          crumb: {}
          gitHostKeyVerificationConfiguration:
            sshHostKeyVerificationStrategy: "knownHostsFileVerificationStrategy"
          prism: {}
          queueItemAuthenticator: {}
          sSHD:
            port: -1
          scriptApproval:
            forceSandbox: false
          updateSiteWarningsConfiguration: {}
        unclassified:
          administrativeMonitorsConfiguration: {}
          artifactManager: {}
          buildDiscarders:
            configuredBuildDiscarders:
            - "jobBuildDiscarder"
          builtInNode: {}
          casCGlobalConfig: {}
          computerRetentionCheckInterval: {}
          defaultDisplayUrlProvider: {}
          defaultFolderConfiguration: {}
          defaultView: {}
          envVarsFilter: {}
          fingerprints:
            fingerprintCleanupDisabled: false
            storage: "file"
          globalDefaultFlowDurabilityLevel: {}
          globalLibraries: {}
          globalUntrustedLibraries: {}
          junitTestResultStorage:
            storage: "file"
          location:
            adminAddress: "${var.name_jenkins}@${var.keycloak_realm}"
            url: "https://${var.name_jenkins}.${var.dns_private_zone_name}/"
          mailer:
            charset: "UTF-8"
            useSsl: false
            useTls: false
          metricsAccessKey: {}
          myView: {}
          nodeProperties: {}
          plugin: {}
          pollSCM:
            pollingThreadCount: 10
          projectNamingStrategy: {}
          proxyConfigurationManager: {}
          quietPeriod: {}
          resourceRoot: {}
          scmRetryCount: {}
          shell: {}
          usageStatistics: {}
          viewsTabBar: {}
        tool:
          git:
            installations:
            - home: "git"
              name: "Default"
          mavenGlobalConfig:
            globalSettingsProvider: "standard"
            settingsProvider: "standard"
EOF
  ]
}

output "jenkins_admin_password" {
  value = "\n=====\nJenkins password is:\nkubectl -n ${kubernetes_namespace.jenkins.metadata[0].name} get secrets jenkins -o json | jq '.data | map_values(@base64d)'\n"
}
