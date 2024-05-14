provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "microk8s"
  }
}

resource "helm_release" "fluent" {
  name  = "fluent"
  chart = "https://github.com/fluent/helm-charts/releases/download/fluent-bit-0.46.5/fluent-bit-0.46.5.tgz"

  reset_values  = true
  recreate_pods = true

  values = [
    file("${path.module}/fluent-bit/test-values.yaml")
  ]
}


resource "helm_release" "opentelemetry_collector" {
  name  = "collector"
  chart = "https://github.com/open-telemetry/opentelemetry-helm-charts/releases/download/opentelemetry-collector-0.90.1/opentelemetry-collector-0.90.1.tgz"

  reset_values  = true
  recreate_pods = true

  values = [
    file("${path.module}/otel/collector/helm-values.yaml")
  ]
}


# https://github.com/grafana/loki/tree/main/production/helm/loki
resource "helm_release" "loki" {
  name = "loki"

  #   chart = "https://github.com/grafana/helm-charts/releases/download/helm-loki-6.5.2/loki-6.5.2.tgz"

  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  version    = "6.5.2"

  reset_values  = true
  recreate_pods = true

  values = [
    file("${path.module}/otel/loki/test-values.yaml")
  ]
}
