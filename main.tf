provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "microk8s"
  }
}

resource "helm_release" "fluent" {
  name  = "fluent"
  chart = "https://github.com/fluent/helm-charts/releases/download/fluent-bit-0.46.5/fluent-bit-0.46.5.tgz"

  reset_values = true

  values = [
    file("${path.module}/fluent-bit/helm-values.yaml")
  ]
}
