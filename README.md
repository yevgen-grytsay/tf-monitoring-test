
## Debug
```sh
kubectl run curl --image=radial/busyboxplus:curl -i --tty --rm
```

## Resources
### Fluent-bit
- [Filters | Kubernetes](https://docs.fluentbit.io/manual/pipeline/filters/kubernetes)
- [Helm values.yaml](https://raw.githubusercontent.com/fluent/helm-charts/main/charts/fluent-bit/values.yaml)
- [Inputs | OpenTelemetry](https://docs.fluentbit.io/manual/pipeline/inputs/opentelemetry)
- [Outputs | OpenTelemetry](https://docs.fluentbit.io/manual/pipeline/outputs/opentelemetry)

### OpenTelemetry Collector
- [Helm values.yaml](https://github.com/open-telemetry/opentelemetry-helm-charts/blob/main/charts/opentelemetry-collector/values.yaml)