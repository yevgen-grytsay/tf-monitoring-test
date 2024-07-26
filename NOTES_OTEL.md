## Шлях одного логу

### Fluent-Bit Config

```
[INPUT]
    Name tail
    Tag kube.argocd
    Path /var/log/containers/argo-cd-*.log
    Parser cri

[FILTER]
    Name parser
    Match kube.argocd
    Parser logfmt
    Key_Name message
    Reserve_Data True # Просто для прикладу. Так поля cri-формату (logtag, stream, time) не будуть видалені

[FILTER]
    Name Lua
    Match kube.argocd
    call append_severityText
    code function append_severityText(tag, timestamp, record) new_record = record new_record["severityText"] = string.upper(new_record["level"]) return 1, timestamp, new_record end

[OUTPUT]
    Name opentelemetry
    Match kube.*
    Host collector
    Port 3030
    logs_uri /v1/logs
    logs_severity_text_message_key severityText
```

`Reserve_Data True` Тут використовується просто для прикладу. Так поля cri-формату (logtag, stream, time) не будуть видалені

Хоча я використовую дефолтне ім'я для поля severity, все одно довелося його вказати явно параметром `logs_severity_text_message_key severityText`. Без цього не спрацювало.

### ArgoCD Repo Server Logs

```
sudo tail /var/log/containers/argo-cd-argocd-repo-server-54d8b9cf4d-gfnz7_argocd_repo-server-aeb425ec61ac163105b6271b8dc15718333d51c31ec797a5a3a61221b346e467.log

2024-07-25T12:28:25.782840799Z stderr F time="2024-07-25T12:28:25Z" level=info msg="finished unary call with code OK" grpc.code=OK grpc.method=Check grpc.service=grpc.health.v1.Health grpc.start_time="2024-07-25T12:28:25Z" grpc.time_ms=0.028 span.kind=server system=grpc
```

### Fluent-Bit stdout

```
[{"date":1721910505.782841,"stream":"stderr","logtag":"F","grpc.code":"OK","time":"2024-07-25T12:28:25.782840799Z","grpc.method":"Check","level":"info","grpc.service":"grpc.health.v1.Health","grpc.start_time":"2024-07-25T12:28:25Z","msg":"finished unary call with code OK","severityText":"INFO","span.kind":"server","grpc.time_ms":"0.028","system":"grpc"}]
```

### OpenTelemetry Collector

```
2024-07-25T12:28:26.844Z info LogsExporter {"kind": "exporter", "data_type": "logs", "name": "debug", "resource logs": 1, "log records": 1}
2024-07-25T12:28:26.844Z info ResourceLog #0
Resource SchemaURL:
ScopeLogs #0
ScopeLogs SchemaURL:
InstrumentationScope
LogRecord #0
ObservedTimestamp: 1970-01-01 00:00:00 +0000 UTC
Timestamp: 2024-07-25 12:28:25.782840728 +0000 UTC
SeverityText: INFO
SeverityNumber: Unspecified(0)
Body: Map({"grpc.code":"OK","grpc.method":"Check","grpc.service":"grpc.health.v1.Health","grpc.start_time":"2024-07-25T12:28:25Z","grpc.time_ms":"0.028","level":"info","logtag":"F","msg":"finished unary call with code OK","severityText":"INFO","span.kind":"server","stream":"stderr","system":"grpc","time":"2024-07-25T12:28:25.782840799Z"})
Trace ID:
Span ID:
Flags: 0
{"kind": "exporter", "data_type": "logs", "name": "debug"}
```

### Grafana

```json
{
  "body": {
    "grpc.code": "OK",
    "grpc.method": "Check",
    "grpc.service": "grpc.health.v1.Health",
    "grpc.start_time": "2024-07-25T12:28:25Z",
    "grpc.time_ms": "0.028",
    "level": "info",
    "logtag": "F",
    "msg": "finished unary call with code OK",
    "severityText": "INFO",
    "span.kind": "server",
    "stream": "stderr",
    "system": "grpc",
    "time": "2024-07-25T12:28:25.782840799Z"
  },
  "severity": "INFO"
}
```

```
Fields:

exporter: OTLP
level: debug
service_name: unknown_service
```

### Grafana (+ Kubernetes metadata)

```json
{
  "body": {
    "grpc.code": "OK",
    "grpc.method": "Check",
    "grpc.service": "grpc.health.v1.Health",
    "grpc.start_time": "2024-07-25T19:07:35Z",
    "grpc.time_ms": "0.033",
    "kubernetes": {
      "annotations": {
        "checksum/cm": "791ce46261793132cce6264086957ff301eb510e680ed9355a205a22056e9a5f",
        "checksum/cmd-params": "1c4495969eb3ee4e704035c6767fa421040dedd9ba5e3c28b8b610b34a56506f"
      },
      "container_hash": "quay.io/argoproj/argocd@sha256:d2c274ff26c7ab164907de05826bdfe2e6f326af70edd0bb83194b75fbb71f9e",
      "container_image": "quay.io/argoproj/argocd:v2.11.2",
      "container_name": "repo-server",
      "docker_id": "aeb425ec61ac163105b6271b8dc15718333d51c31ec797a5a3a61221b346e467",
      "host": "nuc-1",
      "labels": {
        "app.kubernetes.io/component": "repo-server",
        "app.kubernetes.io/instance": "argo-cd",
        "app.kubernetes.io/managed-by": "Helm",
        "app.kubernetes.io/name": "argocd-repo-server",
        "app.kubernetes.io/part-of": "argocd",
        "app.kubernetes.io/version": "v2.11.2",
        "helm.sh/chart": "argo-cd-6.11.1",
        "pod-template-hash": "54d8b9cf4d"
      },
      "namespace_name": "argocd",
      "pod_id": "d22d24f6-ff93-4740-84d0-9e8b657e5454",
      "pod_name": "argo-cd-argocd-repo-server-54d8b9cf4d-gfnz7"
    },
    "level": "info",
    "msg": "finished unary call with code OK",
    "severityText": "INFO",
    "span.kind": "server",
    "system": "grpc",
    "time": "2024-07-25T19:07:35Z"
  },
  "severity": "INFO"
}
```

Query Example:

```
{exporter="OTLP"} |= `` | json level="body.level", namespace="body.kubernetes.namespace_name" | namespace != `argocd` | namespace != `metallb-system`
```

```json
{
  "kind": "processor",
  "name": "transform",
  "pipeline": "logs",
  "statement": "set(attributes[\"level\"], body[\"level\"])",
  "condition matched": true,
  "TransformContext": {
    "resource": { "attributes": {}, "dropped_attribute_count": 0 },
    "scope": {
      "attributes": {},
      "dropped_attribute_count": 0,
      "name": "",
      "version": ""
    },
    "log_record": {
      "attributes": { "level": "info" },
      "body": "{\"grpc.code\":\"OK\",\"grpc.method\":\"Check\",\"grpc.service\":\"grpc.health.v1.Health\",\"grpc.start_time\":\"2024-07-25T20:13:35Z\",\"grpc.time_ms\":\"0.025\",\"kubernetes\":{\"annotations\":{\"checksum/cm\":\"791ce46261793132cce6264086957ff301eb510e680ed9355a205a22056e9a5f\",\"checksum/cmd-params\":\"1c4495969eb3ee4e704035c6767fa421040dedd9ba5e3c28b8b610b34a56506f\"},\"container_hash\":\"quay.io/argoproj/argocd@sha256:d2c274ff26c7ab164907de05826bdfe2e6f326af70edd0bb83194b75fbb71f9e\",\"container_image\":\"quay.io/argoproj/argocd:v2.11.2\",\"container_name\":\"repo-server\",\"docker_id\":\"aeb425ec61ac163105b6271b8dc15718333d51c31ec797a5a3a61221b346e467\",\"host\":\"nuc-1\",\"labels\":{\"app.kubernetes.io/component\":\"repo-server\",\"app.kubernetes.io/instance\":\"argo-cd\",\"app.kubernetes.io/managed-by\":\"Helm\",\"app.kubernetes.io/name\":\"argocd-repo-server\",\"app.kubernetes.io/part-of\":\"argocd\",\"app.kubernetes.io/version\":\"v2.11.2\",\"helm.sh/chart\":\"argo-cd-6.11.1\",\"pod-template-hash\":\"54d8b9cf4d\"},\"namespace_name\":\"argocd\",\"pod_id\":\"d22d24f6-ff93-4740-84d0-9e8b657e5454\",\"pod_name\":\"argo-cd-argocd-repo-server-54d8b9cf4d-gfnz7\"},\"level\":\"info\",\"msg\":\"finished unary call with code OK\",\"severityText\":\"INFO\",\"span.kind\":\"server\",\"system\":\"grpc\",\"time\":\"2024-07-25T20:13:35Z\"}",
      "dropped_attribute_count": 0,
      "flags": 0,
      "observed_time_unix_nano": 0,
      "severity_number": 0,
      "severity_text": "INFO",
      "span_id": "0000000000000000",
      "time_unix_nano": 1721938415784407615,
      "trace_id": "00000000000000000000000000000000"
    },
    "cache": {}
  },
  "trace_id": "c055f3773f0383aaf9bd347fa88dab9c",
  "span_id": "16665a8cb4936e16"
}
```

[loki distributor | levelLabel = "detected_level"](https://github.com/grafana/loki/blob/v3.1.0/pkg/distributor/distributor.go#L66)
