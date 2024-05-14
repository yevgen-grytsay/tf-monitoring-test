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
curl -H "Content-Type: application/json" -XPOST -s "http://loki:3100/loki/api/v1/push"  \
    --data "{\"streams\": [{\"stream\": {\"job\": \"test\"}, \"values\": [[\"$(date +%s)000000000\", \"fizzbuzz\"]]}]}"

curl "http://loki:3100/loki/api/v1/query_range" --data-urlencode 'query={job="test"}' | jq .data.result
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