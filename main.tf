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
    file("${path.module}/fluent-bit/helm-values.yaml")
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
