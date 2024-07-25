provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "microk8s"
  }
}

resource "helm_release" "fluent" {
  name       = "fluent"
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluent-bit"
  version    = "0.47.4"

  reset_values  = true
  recreate_pods = true  # DEPRECATED in Helm 3 https://helm.sh/docs/intro/using_helm/#helpful-options-for-installupgraderollback

  values = [
    file("${path.module}/otel/fluent-bit/helm-values.yaml")
  ]
}

resource "helm_release" "opentelemetry_collector" {
  name = "collector"
  #   chart = "https://github.com/open-telemetry/opentelemetry-helm-charts/releases/download/opentelemetry-collector-0.90.1/opentelemetry-collector-0.90.1.tgz"
  repository = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart      = "opentelemetry-collector"
  version    = "0.99.0"

  reset_values  = true
  recreate_pods = true  # DEPRECATED in Helm 3 https://helm.sh/docs/intro/using_helm/#helpful-options-for-installupgraderollback

  values = [
    file("${path.module}/otel/collector/helm-values.yaml")
  ]
}

resource "helm_release" "loki" {
  name = "loki"

  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  version    = "6.5.2"

  reset_values  = true
  recreate_pods = true  # DEPRECATED in Helm 3 https://helm.sh/docs/intro/using_helm/#helpful-options-for-installupgraderollback

  values = [
    file("${path.module}/otel/loki/helm-values.yaml")
  ]
}

resource "helm_release" "grafana" {
  name = "grafana"

  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "7.3.11"

  reset_values  = true
  recreate_pods = true  # DEPRECATED in Helm 3 https://helm.sh/docs/intro/using_helm/#helpful-options-for-installupgraderollback

  values = [
    file("${path.module}/otel/grafana/helm-values.yaml")
  ]
}

resource "helm_release" "prometheus" {
  name = "prometheus"

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  version    = "25.21.0"

  reset_values  = true
  recreate_pods = true  # DEPRECATED in Helm 3 https://helm.sh/docs/intro/using_helm/#helpful-options-for-installupgraderollback

  values = [
    file("${path.module}/otel/prometheus/helm-values.yaml")
  ]
}
