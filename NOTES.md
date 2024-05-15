```
[2024/05/13 17:26:06] [ warn] [engine] failed to flush chunk '1-1715620407.414502679.flb', retry in 1234 seconds: task_id=288, input=tail.0 > output=es.0 (out_id=0)
[2024/05/13 17:26:11] [ warn] [net] getaddrinfo(host='elasticsearch-master', err=4): Domain name not found
[2024/05/13 17:26:11] [ warn] [net] getaddrinfo(host='elasticsearch-master', err=4): Domain name not found
[2024/05/13 17:26:11] [ warn] [engine] failed to flush chunk '1-1715620380.635652448.flb', retry in 21 seconds: task_id=202, input=tail.0 > output=es.0 (out_id=0)
[2024/05/13 17:26:11] [ warn] [engine] failed to flush chunk '1-1715620413.849151349.flb', retry in 174 seconds: task_id=309, input=tail.0 > output=es.0 (out_id=0)
[2024/05/13 17:26:15] [ warn] [net] getaddrinfo(host='elasticsearch-master', err=4): Domain name not found
[2024/05/13 17:26:15] [ warn] [engine] failed to flush chunk '1-1715620378.636833416.flb', retry in 1586 seconds: task_id=195, input=tail.0 > output=es.0 (out_id=0)
```

## Loki

```
$ helm status loki
NAME: loki
LAST DEPLOYED: Tue May 14 11:08:00 2024
NAMESPACE: default
STATUS: failed
REVISION: 1
NOTES:
MinIO can be accessed via port 9000 on the following DNS name from within your cluster:
loki-minio.default.svc.cluster.local

To access MinIO from localhost, run the below commands:

  1. export POD_NAME=$(kubectl get pods --namespace default -l "release=loki" -o jsonpath="{.items[0].metadata.name}")

  2. kubectl port-forward $POD_NAME 9000 --namespace default

Read more about port forwarding here: http://kubernetes.io/docs/user-guide/kubectl/kubectl_port-forward/

You can now access MinIO server on http://localhost:9000. Follow the below steps to connect to MinIO server with mc client:

  1. Download the MinIO mc client - https://docs.minio.io/docs/minio-client-quickstart-guide

  2. export MC_HOST_loki-minio-local=http://$(kubectl get secret --namespace default loki-minio -o jsonpath="{.data.rootUser}" | base64 --decode):$(kubectl get secret --namespace default loki-minio -o jsonpath="{.data.rootPassword}" | base64 --decode)@localhost:9000

  3. mc ls loki-minio-local



***********************************************************************
 Welcome to Grafana Loki
 Chart version: 6.5.2
 Chart Name: loki
 Loki version: 3.0.0
***********************************************************************

** Please be patient while the chart is being deployed **

Tip:

  Watch the deployment status using the command: kubectl get pods -w --namespace default

If pods are taking too long to schedule make sure pod affinity can be fulfilled in the current cluster.

***********************************************************************
Installed components:
***********************************************************************
* loki

Loki has been deployed as a single binary.
This means a single pod is handling reads and writes. You can scale that pod vertically by adding more CPU and memory resources.


***********************************************************************
Sending logs to Loki
***********************************************************************

Loki has been configured with a gateway (nginx) to support reads and writes from a single component.

You can send logs from inside the cluster using the cluster DNS:

http://loki-gateway.default.svc.cluster.local/loki/api/v1/push

You can test to send data from outside the cluster by port-forwarding the gateway to your local machine:

  kubectl port-forward --namespace default svc/loki-gateway 3100:80 &

And then using http://127.0.0.1:3100/loki/api/v1/push URL as shown below:

```
curl -H "Content-Type: application/json" -XPOST -s "http://127.0.0.1:3100/loki/api/v1/push"  \
--data-raw "{\"streams\": [{\"stream\": {\"job\": \"test\"}, \"values\": [[\"$(date +%s)000000000\", \"fizzbuzz\"]]}]}"
```

Then verify that Loki did received the data using the following command:

```
curl "http://127.0.0.1:3100/loki/api/v1/query_range" --data-urlencode 'query={job="test"}' | jq .data.result
```

***********************************************************************
Connecting Grafana to Loki
***********************************************************************

If Grafana operates within the cluster, you'll set up a new Loki datasource by utilizing the following URL:

http://loki-gateway.default.svc.cluster.local/
```


```sh
logcli query '{exporter="OTLP"}'
```

```sh
curl -H "Content-Type: application/json" -XPOST -s "http://loki:3100/loki/api/v1/push"  \
    --data "{\"streams\": [{\"stream\": {\"job\": \"test\"}, \"values\": [[\"$(date +%s)000000000\", \"fizzbuzz\"]]}]}"

curl -H "Content-Type: application/json" -XPOST -s "http://loki:3100/loki/api/v1/push" --data "{\"streams\": [{\"stream\": {\"job\": \"test\"}, \"values\": [[\"$(date +%s)000000000\", \"fizzbuzz\"]]}]}"

curl "http://loki:3100/loki/api/v1/query_range" --data-urlencode 'query={job="test"}' | jq .data.result
```

```sh
kubectl port-forward --namespace default svc/loki-gateway 3100:80 &
curl "http://127.0.0.1:3100/loki/api/v1/query_range" --data-urlencode 'query={job="test"}' | jq .data.result

wget https://github.com/grafana/loki/releases/download/v2.9.8/logcli_2.9.8_amd64.deb

export LOKI_ADDR=http://127.0.0.1:3100


logcli labels job
2024/05/14 12:42:24 http://127.0.0.1:3100/loki/api/v1/label/job/values?end=1715679744584505951&start=1715676144584505951
test
test2



logcli labels pod \
    --timezone=UTC \
    --from="2024-05-13T10:00:00Z" \
    --to="2024-05-15T20:00:00Z"

```


## Chunks cache fail
```
$ kubectl describe pod loki-chunks-cache-0
Name:             loki-chunks-cache-0
Namespace:        default
Priority:         0
Service Account:  loki
Node:             <none>
Labels:           app.kubernetes.io/component=memcached-chunks-cache
                  app.kubernetes.io/instance=loki
                  app.kubernetes.io/name=loki
                  apps.kubernetes.io/pod-index=0
                  controller-revision-hash=loki-chunks-cache-dbf664dd6
                  name=memcached-chunks-cache
                  statefulset.kubernetes.io/pod-name=loki-chunks-cache-0
Annotations:      <none>
Status:           Pending
IP:               
IPs:              <none>
Controlled By:    StatefulSet/loki-chunks-cache
Containers:
  memcached:
    Image:      memcached:1.6.23-alpine
    Port:       11211/TCP
    Host Port:  0/TCP
    Args:
      -m 8192
      --extended=modern,track_sizes
      -I 5m
      -c 16384
      -v
      -u 11211
    Limits:
      memory:  9830Mi
    Requests:
      cpu:        500m
      memory:     9830Mi
    Environment:  <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-4q8f2 (ro)
  exporter:
    Image:      prom/memcached-exporter:v0.14.2
    Port:       9150/TCP
    Host Port:  0/TCP
    Args:
      --memcached.address=localhost:11211
      --web.listen-address=0.0.0.0:9150
    Environment:  <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-4q8f2 (ro)
Conditions:
  Type           Status
  PodScheduled   False 
Volumes:
  kube-api-access-4q8f2:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   Burstable
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason            Age                From               Message
  ----     ------            ----               ----               -------
  Warning  FailedScheduling  55s                default-scheduler  0/1 nodes are available: 1 Insufficient memory. preemption: 0/1 nodes are available: 1 No preemption victims found for incoming pod.
  Warning  FailedScheduling  49s (x2 over 53s)  default-scheduler  0/1 nodes are available: 1 Insufficient memory. preemption: 0/1 nodes are available: 1 No preemption victims found for incoming pod.
```

## Import failed loki to Terraform
```sh
$ terraform import helm_release.loki loki
helm_release.loki: Importing from ID "loki"...
╷
│ Error: Unable to parse identifier loki: Unexpected ID format ("loki"), expected namespace/name
│ 
│ 
╵

$ terraform import helm_release.loki default/loki
```



2024-05-14T13:10:59+03:00 {level="debug"} {"body":"level=info ts=2024-05-14T10:10:59.332299273Z caller=metrics.go:216 component=frontend org_id=fake traceID=5c319a05278c287e latency=fast query=\"{exporter=\\\"OTLP\\\"}\" query_hash=470100140 query_type=limited range_type=range length=1h0m0s start_delta=1h0m0.120213473s end_delta=120.213684ms step=14s duration=59.813513ms status=200 limit=30 returned_lines=0 throughput=52MB total_bytes=3.1MB total_bytes_structured_metadata=685kB lines_per_second=392586 total_lines=23482 post_filter_lines=23482 total_entries=30 store_chunks_download_time=0s queue_time=179µs splits=1 shards=0 query_referenced_structured_metadata=false pipeline_wrapper_filtered_lines=0 chunk_refs_fetch_time=167.52µs cache_chunk_req=0 cache_chunk_hit=0 cache_chunk_bytes_stored=0 cache_chunk_bytes_fetched=0 cache_chunk_download_time=0s cache_index_req=0 cache_index_hit=0 cache_index_download_time=0s cache_stats_results_req=0 cache_stats_results_hit=0 cache_stats_results_download_time=0s cache_volume_results_req=0 cache_volume_results_hit=0 cache_volume_results_download_time=0s cache_result_req=0 cache_result_hit=0 cache_result_download_time=0s cache_result_query_length_served=0s ingester_chunk_refs=0 ingester_chunk_downloaded=0 ingester_chunk_matches=1 ingester_requests=1 ingester_chunk_head_bytes=84kB ingester_chunk_compressed_bytes=431kB ingester_chunk_decompressed_bytes=3.0MB ingester_post_filter_lines=23482 congestion_control_latency=0s index_total_chunks=0 index_post_bloom_filter_chunks=0 index_bloom_filter_ratio=0.00 disable_pipeline_wrappers=false"}



2024-05-14T13:22:28+03:00 {level="error"} {"body":"level=error ts=2024-05-14T10:22:28.414286285Z caller=flush.go:152 component=ingester org_id=fake msg=\"failed to flush\" err=\"failed to flush chunks: store put chunk: mkdir fake: read-only file system, num_chunks: 2, labels: {exporter=\\\"OTLP\\\", service_name=\\\"unknown_service\\\"}\""}



## Grafana
```
$ helm status grafana
NAME: grafana
LAST DEPLOYED: Tue May 14 15:25:39 2024
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
1. Get your 'admin' user password by running:

   kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo


2. The Grafana server can be accessed via port 80 on the following DNS name from within your cluster:

   grafana.default.svc.cluster.local

   Get the Grafana URL to visit by running these commands in the same shell:
     export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=grafana" -o jsonpath="{.items[0].metadata.name}")
     kubectl --namespace default port-forward $POD_NAME 3000

3. Login with the password from step 1 and the username: admin
#################################################################################
######   WARNING: Persistence is disabled!!! You will lose your data when   #####
######            the Grafana pod is terminated.                            #####
#################################################################################
```

```sh
export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=grafana" -o jsonpath="{.items[0].metadata.name}")

kubectl --namespace default --address 192.168.1.119 port-forward $POD_NAME 3000
```

## Prometheus
### Helm release status
```
NAME: prometheus
LAST DEPLOYED: Tue May 14 21:41:35 2024
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=prometheus-node-exporter,app.kubernetes.io/instance=prometheus" -o jsonpath="{.items[0].metadata.name}")
  echo "Visit http://127.0.0.1:9100 to use your application"
  kubectl port-forward --namespace default $POD_NAME 9100
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=prometheus-pushgateway,app.kubernetes.io/instance=prometheus" -o jsonpath="{.items[0].metadata.name}")
  kubectl port-forward $POD_NAME 9091
  echo "Visit http://127.0.0.1:9091 to use your application"

kube-state-metrics is a simple service that listens to the Kubernetes API server and generates metrics about the state of the objects.
The exposed metrics can be found here:
https://github.com/kubernetes/kube-state-metrics/blob/master/docs/README.md#exposed-metrics

The metrics are exported on the HTTP endpoint /metrics on the listening port.
In your case, prometheus-kube-state-metrics.default.svc.cluster.local:8080/metrics

They are served either as plaintext or protobuf depending on the Accept header.
They are designed to be consumed either by Prometheus itself or by a scraper that is compatible with scraping a Prometheus client endpoint.

1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=alertmanager,app.kubernetes.io/instance=prometheus" -o jsonpath="{.items[0].metadata.name}")
  echo "Visit http://127.0.0.1:9093 to use your application"
  kubectl --namespace default port-forward $POD_NAME 9093:80

The Prometheus server can be accessed via port 80 on the following DNS name from within your cluster:
prometheus-server.default.svc.cluster.local


Get the Prometheus server URL by running these commands in the same shell:
  export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=prometheus,app.kubernetes.io/instance=prometheus" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace default port-forward $POD_NAME 9090


The Prometheus alertmanager can be accessed via port 9093 on the following DNS name from within your cluster:
prometheus-alertmanager.default.svc.cluster.local


Get the Alertmanager URL by running these commands in the same shell:
  export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=alertmanager,app.kubernetes.io/instance=prometheus" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace default port-forward $POD_NAME 9093
#################################################################################
######   WARNING: Pod Security Policy has been disabled by default since    #####
######            it deprecated after k8s 1.25+. use                        #####
######            (index .Values "prometheus-node-exporter" "rbac"          #####
###### .          "pspEnabled") with (index .Values                         #####
######            "prometheus-node-exporter" "rbac" "pspAnnotations")       #####
######            in case you still need it.                                #####
#################################################################################


The Prometheus PushGateway can be accessed via port 9091 on the following DNS name from within your cluster:
prometheus-prometheus-pushgateway.default.svc.cluster.local


Get the PushGateway URL by running these commands in the same shell:
  export POD_NAME=$(kubectl get pods --namespace default -l "app=prometheus-pushgateway,component=pushgateway" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace default port-forward $POD_NAME 9091

For more information on running Prometheus, visit:
https://prometheus.io/
```



```
NAME: prometheus
LAST DEPLOYED: Tue May 14 22:04:48 2024
NAMESPACE: default
STATUS: deployed
REVISION: 3
TEST SUITE: None
NOTES:
The Prometheus server can be accessed via port 80 on the following DNS name from within your cluster:
prometheus-server.default.svc.cluster.local


Get the Prometheus server URL by running these commands in the same shell:
  export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=prometheus,app.kubernetes.io/instance=prometheus" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace default port-forward $POD_NAME 9090





For more information on running Prometheus, visit:
https://prometheus.io/
```
