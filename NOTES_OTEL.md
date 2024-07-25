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
