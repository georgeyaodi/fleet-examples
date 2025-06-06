# Milvus Helm Chart

For more information about installing and using Helm, see the [Helm Docs](https://helm.sh/docs/). For a quick introduction to Charts, see the [Chart Guide](https://helm.sh/docs/topics/charts/).

## Introduction
This chart bootstraps Milvus deployment on a Kubernetes cluster using the Helm package manager.

## Prerequisites

- Kubernetes 1.14+ (Attu requires 1.18+)
- Helm >= 3.2.0

## Unsupported features for this release
SUSE does not support enabling heaptrack, attu, pulsar.

### Deploy Milvus with standalone mode

Assume the release name is `my-release`:

```bash
# Helm v3.x
$ helm upgrade --install my-release --set global.imagePullSecrets[0].name=my-pull-secrets --set cluster.enabled=false --set etcd.replicaCount=1 --set kafka.enabled=false --set minio.mode=standalone oci://dp.apps.rancher.io/charts/milvus
```
By default, milvus standalone uses `rocksmq` as message queue. You can also use `kafka` as message queue:

```bash
# Helm v3.x
# Milvus Standalone with kafka as message queue
$ helm upgrade --install my-release --set global.imagePullSecrets[0].name=my-pull-secrets --set cluster.enabled=false --set standalone.messageQueue=kafka --set etcd.replicaCount=1 --set kafka.enabled=true --set minio.mode=standalone oci://dp.apps.rancher.io/charts/milvus
```

If you need to use standalone mode with embedded ETCD and local storage (without starting MinIO and additional ETCD), you can use the following steps:

1. Prepare a values file
```
cat > values.yaml <<EOF
---
global:
  imagePullSecrets:
  - my-pull-secret

cluster:
  enabled: false

etcd:
  enabled: false

minio:
  enabled: false
  tls:
    enabled: false

extraConfigFiles:
  user.yaml: |+
    etcd:
      use:
        embed: true
      data:
        dir: /var/lib/milvus/etcd
    common:
      storageType: local
EOF

```

2. Helm install with this values file
```
helm upgrade --install -f values.yaml my-release oci://dp.apps.rancher.io/charts/milvus

```

> **Tip**: To list all releases, using `helm list`.

### Deploy Milvus with cluster mode

Assume the release name is `my-release`:

```bash
# Helm v3.x
$ helm upgrade --install my-release oci://dp.apps.rancher.io/charts/milvus
```
By default, milvus cluster uses `kafka` as message queue. 

By default, milvus cluster uses several separate coordinators. You can also use mixCoordinator instead which contains all coordinators.

```bash
# Helm v3.x
$ cat << EOF > values-custom.yaml
mixCoordinator:
  enabled: true
rootCoordinator:
  enabled: false
indexCoordinator:
  enabled: false
queryCoordinator:
  enabled: false
dataCoordinator:
  enabled: false
EOF
$ helm upgrade --install my-release -f values-custom.yaml oci://dp.apps.rancher.io/charts/milvus
```

### Upgrade an existing Milvus cluster

> **IMPORTANT** If you have installed a milvus cluster with version below v2.1.x, you need follow the instructions at here: https://github.com/milvus-io/milvus/blob/master/deployments/migrate-meta/README.md. After meta migration, you use `helm upgrade` to update your cluster again.

E.g. to scale out query node from 1(default) to 2:

```bash
# Helm v3.x
$ helm upgrade --install --set queryNode.replicas=2 my-release oci://dp.apps.rancher.io/charts/milvus
```

### Enable log to file

By default, all the logs of milvus components will output stdout. If you wanna log to file, you'd install milvus with `--set log.persistence.enabled=true`. Note that you should have a storageclass with `ReadWriteMany` access modes.

```bash
# Install a milvus cluster with file log output
helm install my-release --set log.persistence.enabled=true --set log.persistence.persistentVolumeClaim.storageClass=<read-write-many-storageclass> oci://dp.apps.rancher.io/charts/milvus
```

It will output log to `/milvus/logs/` directory.

### Enable proxy tls connection
By default the TLS connection to proxy service is false, to enable TLS with users' own certificate and privatge key, it can be specified in `extraConfigFiles` like this:

```bash
extraConfigFiles:
  user.yaml: |+
    #  Enable tlsMode and set the tls cert and key
       tls:
        serverPemPath: /etc/milvus/certs/tls.crt
        serverKeyPath: /etc/milvus/certs/tls.key
       common:
         security:
           tlsMode: 1

```
The path specified above are TLS secret data  mounted inside the proxy pod as files. To create a TLS secret, set `proxy.tls.enabled` to `true` then provide base64-encoded values for your certificate and private key files in values.yaml:

```bash
proxy:
  enabled: true
  tls:
    enabled: true
    secretName: milvus-tls
  #expecting base64 encoded values here: i.e. $(cat tls.crt | base64 -w 0) and $(cat tls.key | base64 -w 0)
    key: LS0tLS1C....
    crt: LS0tLS1CR...
```
or in cli using --set:

```bash
  --set proxy.tls.enabled=true \
  --set prox.tls.key=$(cat /path/to/private_key_file | base64 -w 0) \
  --set prox.tls.crt=$(cat /path/to/certificate_file | base64 -w 0)
```
In case you want to use a different `secretName` or mount path inside pod, modify `prox.tls.secretName` above, and `serverPemPath` and `serverPemPath` in `extraConfigFles `accordingly, then in the `volume` and `volumeMounts` sections in values.yaml

```bash
  volumes:
  - secret:
      secretName: Your-tls-secret-name
    name: milvus-tls
  volumeMounts:
  - mountPath: /Your/tls/files/path/
    name: milvus-tls
```

## Milvus with External Object Storage

As of https://github.com/minio/minio/releases/tag/RELEASE.2022-10-29T06-21-33Z, the MinIO Gateway and the related filesystem mode code have been removed. It is now recommended to utilize the `externalS3` configuration for integrating with various object storage services. Notably, Milvus now provides support for popular object storage platforms such as AWS S3, GCP GCS, Azure Blob, Aliyun OSS and Tencent COS.

The recommended configuration option for `externalS3.cloudProvider` includes the following choices: `aws`, `gcp`, `azure`, `aliyun`, and `tencent`. Here's an example to use AWS S3 for Milvus object storage:

```
minio:
  enabled: false
externalS3:
  enabled: true
  cloudProvider: aws
  host: s3.aws.com
  port: 443
  useSSL: true
  bucketName: <bucket-name>
  accessKey: <s3-access-key>
  secretKey: <s3-secret-key>
```


## Uninstall the Chart

```bash
# Helm v3.x
$ helm uninstall my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

- Completely uninstall Milvus

> **IMPORTANT** Please run this command with care. Maybe you want to keep ETCD data
```bash
MILVUS_LABELS="app.kubernetes.io/instance=my-release"
kubectl delete pvc $(kubectl get pvc -l "${MILVUS_LABELS}" -o jsonpath='{range.items[*]}{.metadata.name} ')
```

## Configuration

### Milvus Service Configuration

The following table lists the configurable parameters of the Milvus Service and their default values.

| Parameter                                 | Description                                   | Default                                                 |
|-------------------------------------------|-----------------------------------------------|---------------------------------------------------------|
| `cluster.enabled`                         | Enable or disable Milvus Cluster mode         | `true`                                                 |
| `image.all.repository`                    | Image repository                              | `milvusdb/milvus`                                       |
| `image.all.tag`                           | Image tag                                     | `v2.4.6`                           |
| `image.all.pullPolicy`                    | Image pull policy                             | `IfNotPresent`                                          |
| `image.all.pullSecrets`                   | Image pull secrets                            | `{}`                                                    |
| `customConfigMap`                         | User specified ConfigMap for configuration    |
| `extraConfigFiles`                        | Extra config to override default milvus.yaml  | `user.yaml:`                                                     |
| `service.type`                            | Service type                                  | `ClusterIP`                                             |
| `service.port`                            | Port where service is exposed                 | `19530`                                                 |
| `service.portName`                        | Useful for [Istio protocol selection](https://istio.io/latest/docs/ops/configuration/traffic-management/protocol-selection/)   | `milvus`                                                |
| `service.nodePort`                        | Service nodePort                              | `unset`                                                 |
| `service.annotations`                     | Service annotations                           | `{}`                                                    |
| `service.labels`                          | Service custom labels                         | `{}`                                                    |
| `service.clusterIP`                       | Internal cluster service IP                   | `unset`                                                 |
| `service.loadBalancerIP`                  | IP address to assign to load balancer (if supported) | `unset`                                          |
| `service.loadBalancerSourceRanges`        | List of IP CIDRs allowed access to lb (if supported) | `[]`                                             |
| `service.externalIPs`                     | Service external IP addresses                 | `[]`                                                    |
| `ingress.enabled`                         | If true, Ingress will be created              | `false`                                                 |
| `ingress.annotations`                     | Ingress annotations                           | `{}`                                                    |
| `ingress.labels`                          | Ingress labels                                | `{}`                                                    |
| `ingress.rules`                           | Ingress rules                                 | `[]`                                                    |
| `ingress.tls`                             | Ingress TLS configuration                     | `[]`                                                    |
| `serviceAccount.create`                   | Create a custom service account               | `false`                                                 |
| `serviceAccount.name`                     | Service Account name                          | `milvus`                                                |
| `serviceAccount.annotations`              | Service Account Annotations                   | `{}`                                                    |
| `serviceAccount.labels`                   | Service Account labels                        | `{}`                                                    |
| `metrics.enabled`                         | Export Prometheus monitoring metrics          | `true`                                                  |
| `metrics.serviceMonitor.enabled`          | Create ServiceMonitor for Prometheus operator | `false`                                                 |
| `metrics.serviceMonitor.additionalLabels` | Additional labels that can be used so ServiceMonitor will be discovered by Prometheus | `unset`         |
| `log.level`                               | Logging level to be used. Valid levels are `debug`, `info`, `warn`, `error`, `fatal` | `info`          |
| `log.file.maxSize`                        | The size limit of the log file (MB)           | `300`                                                   |
| `log.file.maxAge`                         | The maximum number of days that the log is retained. (day) | `10`                                       |
| `log.file.maxBackups`                     | The maximum number of retained logs.          | `20`                                                    |
| `log.format`                              | Format used for the logs. Valid formats are `text` and `json` | `text`                                  |
| `log.persistence.enabled`                 | Use persistent volume to store Milvus logs data | `false`                                               |
| `log.persistence.mountPath`               | Milvus logs data persistence volume mount path | `/milvus/logs`                                         |
| `log.persistence.annotations`             | PersistentVolumeClaim annotations             | `{}`                                                    |
| `log.persistence.persistentVolumeClaim.existingClaim` | Use your own data Persistent Volume existing claim name | `unset`                           |
| `log.persistence.persistentVolumeClaim.storageClass` | The Milvus logs data Persistent Volume Storage Class | `unset`                               |
| `log.persistence.persistentVolumeClaim.accessModes` | The Milvus logs data Persistence access modes | `ReadWriteOnce`                               |
| `log.persistence.persistentVolumeClaim.size` | The size of Milvus logs data Persistent Volume Storage Class | `5Gi`                                 |
| `log.persistence.persistentVolumeClaim.subPath` | SubPath for Milvus logs data mount | `unset`                                                      |
| `externalS3.enabled`                      | Enable or disable external S3                 | `false`                                                 |
| `externalS3.host`                         | The host of the external S3                   | `unset`                                                 |
| `externalS3.port`                         | The port of the external S3                   | `unset`                                                 |
| `externalS3.rootPath`                     | The path prefix of the external S3            | `unset`                                                 |
| `externalS3.accessKey`                    | The Access Key of the external S3             | `unset`                                                 |
| `externalS3.secretKey`                    | The Secret Key of the external S3             | `unset`                                                 |
| `externalS3.bucketName`                   | The Bucket Name of the external S3            | `unset`                                                 |
| `externalS3.useSSL`                       | If true, use SSL to connect to the external S3 | `false`                                                |
| `externalS3.useIAM`                       | If true, use iam to connect to the external S3 | `false`                                                |
| `externalS3.cloudProvider`                | When `useIAM` enabled, only "aws" & "gcp" is supported for now | `aws`                                  |
| `externalS3.iamEndpoint`                  | The IAM endpoint of  the external S3 | ``                                                |
| `externalS3.region`                  | The region of  the external S3 | ``                                                |
| `externalS3.useVirtualHost`                  | If true, the external S3 whether use virtual host bucket mode | ``                                                |
| `externalEtcd.enabled`                    | Enable or disable external Etcd               | `false`                                                 |
| `externalEtcd.endpoints`                  | The endpoints of the external etcd            | `{}`                                                    |
| `externalPulsar.enabled`                  | Enable or disable external Pulsar             | `false`                                                 |
| `externalPulsar.host`                     | The host of the external Pulsar               | `localhost`                                             |
| `externalPulsar.port`                     | The port of the external Pulsar               | `6650`                                                  |
| `externalPulsar.tenant`                   | The tenant of the external Pulsar             | `public`                                                  |
| `externalPulsar.namespace`                | The namespace of the external Pulsar          | `default`                                                  |
| `externalPulsar.authPlugin`               | The authPlugin of the external Pulsar         | `""`                                                  |
| `externalPulsar.authParams`               | The authParams of the external Pulsar         | `""`                                                  |
| `externalKafka.enabled`                   | Enable or disable external Kafka             | `false`                                                 |
| `externalKafka.brokerList`                | The brokerList of the external Kafka separated by comma               | `localhost:9092`                                             |
| `externalKafka.securityProtocol`          | The securityProtocol used for kafka authentication                    | `SASL_SSL`                                                   |
| `externalKafka.sasl.mechanisms`           | SASL mechanism to use for kafka authentication                        | `PLAIN`                                                      |
| `externalKafka.sasl.username`             | username for PLAIN or SASL/PLAIN authentication                       | ``                                                           |
| `externalKafka.sasl.password`             | password for PLAIN or SASL/PLAIN authentication                       | ``                                                           |

### Milvus Standalone Deployment Configuration

The following table lists the configurable parameters of the Milvus Standalone component and their default values.

| Parameter                                 | Description                                   | Default                                                 |
|-------------------------------------------|-----------------------------------------------|---------------------------------------------------------|
| `standalone.resources`                    | Resource requests/limits for the Milvus Standalone pods | `{}`                                          |
| `standalone.nodeSelector`                 | Node labels for Milvus Standalone pods assignment | `{}`                                                |
| `standalone.affinity`                     | Affinity settings for Milvus Standalone pods assignment | `{}`                                          |
| `standalone.tolerations`                  | Toleration labels for Milvus Standalone pods assignment | `[]`                                          |
| `standalone.heaptrack.enabled`            | Whether to enable heaptrack                             | `false`                                          |
| `standalone.disk.enabled`                 | Whether to enable disk                             | `true`                                          |
| `standalone.profiling.enabled`            | Whether to enable live profiling                   | `false`                                          |
| `standalone.extraEnv`                     | Additional Milvus Standalone container environment variables | `[]`                                     |
| `standalone.messageQueue`                 | Message queue for Milvus Standalone: rocksmq, natsmq, kafka | `rocksmq`                                     |
| `standalone.persistence.enabled`          | Use persistent volume to store Milvus standalone data | `true`                                          |
| `standalone.persistence.mountPath` | Milvus standalone data persistence volume mount path | `/var/lib/milvus`                                       |
| `standalone.persistence.annotations`      | PersistentVolumeClaim annotations             | `{}`                                                    |
| `standalone.persistence.persistentVolumeClaim.existingClaim` | Use your own data Persistent Volume existing claim name | `unset`                    |
| `standalone.persistence.persistentVolumeClaim.storageClass` | The Milvus standalone data Persistent Volume Storage Class | `unset`                  |
| `standalone.persistence.persistentVolumeClaim.accessModes` | The Milvus standalone data Persistence access modes | `ReadWriteOnce`                  |
| `standalone.persistence.persistentVolumeClaim.size` | The size of Milvus standalone data Persistent Volume Storage Class | `5Gi`                    |
| `standalone.persistence.persistentVolumeClaim.subPath` | SubPath for Milvus standalone data mount | `unset`                                         |

### Milvus Proxy Deployment Configuration

The following table lists the configurable parameters of the Milvus Proxy component and their default values.

| Parameter                                 | Description                                             | Default       |
|-------------------------------------------|---------------------------------------------------------|---------------|
| `proxy.enabled`                           | Enable or disable Milvus Proxy Deployment               | `true`        |
| `proxy.replicas`                          | Desired number of Milvus Proxy pods                     | `1`           |
| `proxy.resources`                         | Resource requests/limits for the Milvus Proxy pods      | `{}`          |
| `proxy.nodeSelector`                      | Node labels for Milvus Proxy pods assignment            | `{}`          |
| `proxy.affinity`                          | Affinity settings for Milvus Proxy pods assignment      | `{}`          |
| `proxy.tolerations`                       | Toleration labels for Milvus Proxy pods assignment      | `[]`          |
| `proxy.heaptrack.enabled`                 | Whether to enable heaptrack                             | `false`       |
| `proxy.profiling.enabled`                 | Whether to enable live profiling                        | `false`       |
| `proxy.extraEnv`                          | Additional Milvus Proxy container environment variables | `[]`          |
| `proxy.http.enabled`                      | Enable rest api for Milvus Proxy                        | `true`        |
| `proxy.maxUserNum`                       | Modify the Milvus maximum user limit                    | `100`         |
| `proxy.maxRoleNum`                       | Modify the Milvus maximum role limit                    | `10`          |
| `proxy.http.debugMode.enabled`            | Enable debug mode for rest api                          | `false`       |
| `proxy.tls.enabled`                       | Enable porxy tls connection                             | `false`       |
| `proxy.strategy`                          | Deployment strategy configuration                       | RollingUpdate |

### Milvus Root Coordinator Deployment Configuration

The following table lists the configurable parameters of the Milvus Root Coordinator component and their default values.

| Parameter                                 | Description                                   | Default                                                 |
|-------------------------------------------|-----------------------------------------------|---------------------------------------------------------|
| `rootCoordinator.enabled`                 | Enable or disable Milvus Root Coordinator component  | `true`                                           |
| `rootCoordinator.resources`               | Resource requests/limits for the Milvus Root Coordinator pods | `{}`                                    |
| `rootCoordinator.nodeSelector`            | Node labels for Milvus Root Coordinator pods assignment | `{}`                                          |
| `rootCoordinator.affinity`                | Affinity settings for Milvus Root Coordinator pods assignment | `{}`                                    |
| `rootCoordinator.tolerations`             | Toleration labels for Milvus Root Coordinator pods assignment | `[]`                                    |
| `rootCoordinator.heaptrack.enabled`       | Whether to enable heaptrack                             | `false`                                          |
| `rootCoordinator.profiling.enabled`       | Whether to enable live profiling                   | `false`                                          |
| `rootCoordinator.activeStandby.enabled`   | Whether to enable active-standby                   | `false`                                          |
| `rootCoordinator.extraEnv`                | Additional Milvus Root Coordinator container environment variables | `[]`                               |
| `rootCoordinator.service.type`                    | Service type                                  | `ClusterIP`                                  |
| `rootCoordinator.service.port`                    | Port where service is exposed                 | `19530`                                      |
| `rootCoordinator.service.annotations`             | Service annotations                           | `{}`                                         |
| `rootCoordinator.service.labels`                  | Service custom labels                         | `{}`                                         |
| `rootCoordinator.service.clusterIP`               | Internal cluster service IP                   | `unset`                                      |
| `rootCoordinator.service.loadBalancerIP`          | IP address to assign to load balancer (if supported) | `unset`                               |
| `rootCoordinator.service.loadBalancerSourceRanges` | List of IP CIDRs allowed access to lb (if supported) | `[]`                                  |
| `rootCoordinator.service.externalIPs`             | Service external IP addresses                 | `[]`                                         |
| `rootCoordinator.strategy`                       | Deployment strategy configuration |  RollingUpdate                                         |
### Milvus Query Coordinator Deployment Configuration

The following table lists the configurable parameters of the Milvus Query Coordinator component and their default values.

| Parameter                                 | Description                                   | Default                                                 |
|-------------------------------------------|-----------------------------------------------|---------------------------------------------------------|
| `queryCoordinator.enabled`                | Enable or disable Query Coordinator component | `true`                                                  |
| `queryCoordinator.resources`              | Resource requests/limits for the Milvus Query Coordinator pods | `{}`                                   |
| `queryCoordinator.nodeSelector`           | Node labels for Milvus Query Coordinator pods assignment | `{}`                                         |
| `queryCoordinator.affinity`               | Affinity settings for Milvus Query Coordinator pods assignment | `{}`                                   |
| `queryCoordinator.tolerations`            | Toleration labels for Milvus Query Coordinator pods assignment | `[]`                                   |
| `queryCoordinator.heaptrack.enabled`      | Whether to enable heaptrack                             | `false`                                          |
| `queryCoordinator.profiling.enabled`      | Whether to enable live profiling                   | `false`                                          |
| `queryCoordinator.activeStandby.enabled`  | Whether to enable active-standby                   | `false`                                          |
| `queryCoordinator.extraEnv`               | Additional Milvus Query Coordinator container environment variables | `[]`                              |
| `queryCoordinator.service.type`                       | Service type                                  | `ClusterIP`                                 |
| `queryCoordinator.service.port`                       | Port where service is exposed                 | `19530`                                     |
| `queryCoordinator.service.annotations`                | Service annotations                           | `{}`                                        |
| `queryCoordinator.service.labels`                     | Service custom labels                         | `{}`                                        |
| `queryCoordinator.service.clusterIP`                  | Internal cluster service IP                   | `unset`                                     |
| `queryCoordinator.service.loadBalancerIP`             | IP address to assign to load balancer (if supported) | `unset`                              |
| `queryCoordinator.service.loadBalancerSourceRanges`   | List of IP CIDRs allowed access to lb (if supported) | `[]`                                 |
| `queryCoordinator.service.externalIPs`                | Service external IP addresses                 | `[]`                                        |
| `queryCoordinator.strategy`                       | Deployment strategy configuration |  RollingUpdate                                         |
### Milvus Query Node Deployment Configuration

The following table lists the configurable parameters of the Milvus Query Node component and their default values.

| Parameter                                 | Description                                   | Default                                                 |
|-------------------------------------------|-----------------------------------------------|---------------------------------------------------------|
| `queryNode.enabled`                       | Enable or disable Milvus Query Node component | `true`                                                  |
| `queryNode.replicas`                      | Desired number of Milvus Query Node pods | `1`                                                          |
| `queryNode.resources`                     | Resource requests/limits for the Milvus Query Node pods | `{}`                                          |
| `queryNode.nodeSelector`                  | Node labels for Milvus Query Node pods assignment | `{}`                                                |
| `queryNode.affinity`                      | Affinity settings for Milvus Query Node pods assignment | `{}`                                          |
| `queryNode.tolerations`                   | Toleration labels for Milvus Query Node pods assignment | `[]`                                          |
| `queryNode.heaptrack.enabled`             | Whether to enable heaptrack                             | `false`                                          |
| `queryNode.disk.enabled`                  | Whether to enable disk for query                             | `true`                                          |
| `queryNode.profiling.enabled`             | Whether to enable live profiling                   | `false`                                          |
| `queryNode.extraEnv`                      | Additional Milvus Query Node container environment variables | `[]`                                     |
| `queryNode.strategy`                      | Deployment strategy configuration |  RollingUpdate                                         |

### Milvus Index Coordinator Deployment Configuration

The following table lists the configurable parameters of the Milvus Index Coordinator component and their default values.

| Parameter                                 | Description                                   | Default                                                 |
|-------------------------------------------|-----------------------------------------------|---------------------------------------------------------|
| `indexCoordinator.enabled`                | Enable or disable Index Coordinator component | `true`                                                  |
| `indexCoordinator.resources`              | Resource requests/limits for the Milvus Index Coordinator pods | `{}`                                   |
| `indexCoordinator.nodeSelector`           | Node labels for Milvus Index Coordinator pods assignment | `{}`                                         |
| `indexCoordinator.affinity`               | Affinity settings for Milvus Index Coordinator pods assignment | `{}`                                   |
| `indexCoordinator.tolerations`            | Toleration labels for Milvus Index Coordinator pods assignment | `[]`                                   |
| `indexCoordinator.heaptrack.enabled`      | Whether to enable heaptrack                             | `false`                                          |
| `indexCoordinator.profiling.enabled`      | Whether to enable live profiling                   | `false`                                          |
| `indexCoordinator.activeStandby.enabled`  | Whether to enable active-standby                   | `false`                                          |
| `indexCoordinator.extraEnv`               | Additional Milvus Index Coordinator container environment variables | `[]`                              |
| `indexCoordinator.service.type`                       | Service type                                  | `ClusterIP`                                 |
| `indexCoordinator.service.port`                       | Port where service is exposed                 | `19530`                                     |
| `indexCoordinator.service.annotations`                | Service annotations                           | `{}`                                        |
| `indexCoordinator.service.labels`                     | Service custom labels                         | `{}`                                        |
| `indexCoordinator.service.clusterIP`                  | Internal cluster service IP                   | `unset`                                     |
| `indexCoordinator.service.loadBalancerIP`             | IP address to assign to load balancer (if supported) | `unset`                              |
| `indexCoordinator.service.loadBalancerSourceRanges`   | List of IP CIDRs allowed access to lb (if supported) | `[]`                                 |
| `indexCoordinator.service.externalIPs`                | Service external IP addresses                 | `[]`                                        |
| `indexCoordinator.strategy`                       | Deployment strategy configuration |  RollingUpdate                                         |
### Milvus Index Node Deployment Configuration

The following table lists the configurable parameters of the Milvus Index Node component and their default values.

| Parameter                                 | Description                                   | Default                                                 |
|-------------------------------------------|-----------------------------------------------|---------------------------------------------------------|
| `indexNode.enabled`                       | Enable or disable Index Node component        | `true`                                                  |
| `indexNode.replicas`                      | Desired number of Index Node pods             | `1`                                                     |
| `indexNode.resources`                     | Resource requests/limits for the Milvus Index Node pods | `{}`                                          |
| `indexNode.nodeSelector`                  | Node labels for Milvus Index Node pods assignment | `{}`                                                |
| `indexNode.affinity`                      | Affinity settings for Milvus Index Node pods assignment | `{}`                                          |
| `indexNode.tolerations`                   | Toleration labels for Milvus Index Node pods assignment | `[]`                                          |
| `indexNode.heaptrack.enabled`             | Whether to enable heaptrack                             | `false`                                          |
| `indexNode.disk.enabled`                  | Whether to enable disk for index node                             | `true`                                          |
| `indexNode.profiling.enabled`             | Whether to enable live profiling                   | `false`                                          |
| `indexNode.extraEnv`                      | Additional Milvus Index Node container environment variables | `[]`                                     |
| `indexNode.strategy`                      | Deployment strategy configuration |  RollingUpdate                                         |

### Milvus Data Coordinator Deployment Configuration

The following table lists the configurable parameters of the Milvus Data Coordinator component and their default values.

| Parameter                                 | Description                                   | Default                                                 |
|-------------------------------------------|-----------------------------------------------|---------------------------------------------------------|
| `dataCoordinator.enabled`                 | Enable or disable Data Coordinator component  | `true`                                                  |
| `dataCoordinator.resources`               | Resource requests/limits for the Milvus Data Coordinator pods | `{}`                                    |
| `dataCoordinator.nodeSelector`            | Node labels for Milvus Data Coordinator pods assignment | `{}`                                          |
| `dataCoordinator.affinity`                | Affinity settings for Milvus Data Coordinator pods assignment  | `{}`                                   |
| `dataCoordinator.tolerations`             | Toleration labels for Milvus Data Coordinator pods assignment | `[]`                                    |
| `dataCoordinator.heaptrack.enabled`       | Whether to enable heaptrack                             | `false`                                          |
| `dataCoordinator.profiling.enabled`       | Whether to enable live profiling                   | `false`                                          |
| `dataCoordinator.activeStandby.enabled`   | Whether to enable active-standby                   | `false`                                          |
| `dataCoordinator.extraEnv`                | Additional Milvus Data Coordinator container environment variables | `[]`                               |
| `dataCoordinator.service.type`                        | Service type                                  | `ClusterIP`                                 |
| `dataCoordinator.service.port`                        | Port where service is exposed                 | `19530`                                     |
| `dataCoordinator.service.annotations`                 | Service annotations                           | `{}`                                        |
| `dataCoordinator.service.labels`                      | Service custom labels                         | `{}`                                        |
| `dataCoordinator.service.clusterIP`                   | Internal cluster service IP                   | `unset`                                     |
| `dataCoordinator.service.loadBalancerIP`              | IP address to assign to load balancer (if supported) | `unset`                              |
| `dataCoordinator.service.loadBalancerSourceRanges`    | List of IP CIDRs allowed access to lb (if supported) | `[]`                                 |
| `dataCoordinator.service.externalIPs`                 | Service external IP addresses                 | `[]`                                        |
| `dataCoordinator.strategy`                       | Deployment strategy configuration |  RollingUpdate                                         |
### Milvus Data Node Deployment Configuration

The following table lists the configurable parameters of the Milvus Data Node component and their default values.

| Parameter                                 | Description                                   | Default                                                 |
|-------------------------------------------|-----------------------------------------------|---------------------------------------------------------|
| `dataNode.enabled`                        | Enable or disable Data Node component         | `true`                                                  |
| `dataNode.replicas`                       | Desired number of Data Node pods               | `1`                                                    |
| `dataNode.resources`                      | Resource requests/limits for the Milvus Data Node pods | `{}`                                           |
| `dataNode.nodeSelector`                   | Node labels for Milvus Data Node pods assignment | `{}`                                                 |
| `dataNode.affinity`                       | Affinity settings for Milvus Data Node pods assignment | `{}`                                           |
| `dataNode.tolerations`                    | Toleration labels for Milvus Data Node pods assignment | `[]`                                           |
| `dataNode.heaptrack.enabled`              | Whether to enable heaptrack                             | `false`                                          |
| `dataNode.profiling.enabled`              | Whether to enable live profiling                   | `false`                                          |
| `dataNode.extraEnv`                       | Additional Milvus Data Node container environment variables | `[]`                                      |
| `dataNode.strategy`                       | Deployment strategy configuration |  RollingUpdate                                         |

### Milvus Mixture Coordinator Deployment Configuration

The following table lists the configurable parameters of the Milvus Mixture Coordinator component and their default values.

| Parameter                                 | Description                                   | Default                                                 |
|-------------------------------------------|-----------------------------------------------|---------------------------------------------------------|
| `mixCoordinator.enabled`                 | Enable or disable Data Coordinator component  | `true`                                                  |
| `mixCoordinator.resources`               | Resource requests/limits for the Milvus Data Coordinator pods | `{}`                                    |
| `mixCoordinator.nodeSelector`            | Node labels for Milvus Data Coordinator pods assignment | `{}`                                          |
| `mixCoordinator.affinity`                | Affinity settings for Milvus Data Coordinator pods assignment  | `{}`                                   |
| `mixCoordinator.tolerations`             | Toleration labels for Milvus Data Coordinator pods assignment | `[]`                                    |
| `mixCoordinator.heaptrack.enabled`       | Whether to enable heaptrack                             | `false`                                          |
| `mixCoordinator.profiling.enabled`       | Whether to enable live profiling                   | `false`                                          |
| `mixCoordinator.activeStandby.enabled`   | Whether to enable active-standby                   | `false`                                          |
| `mixCoordinator.extraEnv`                | Additional Milvus Data Coordinator container environment variables | `[]`                               |
| `mixCoordinator.service.type`                        | Service type                                  | `ClusterIP`                                 |
| `mixCoordinator.service.annotations`                 | Service annotations                           | `{}`                                        |
| `mixCoordinator.service.labels`                      | Service custom labels                         | `{}`                                        |
| `mixCoordinator.service.clusterIP`                   | Internal cluster service IP                   | `unset`                                     |
| `mixCoordinator.service.loadBalancerIP`              | IP address to assign to load balancer (if supported) | `unset`                              |
| `mixCoordinator.service.loadBalancerSourceRanges`    | List of IP CIDRs allowed access to lb (if supported) | `[]`                                 |
| `mixCoordinator.service.externalIPs`                 | Service external IP addresses                 | `[]`                                        |
| `mixCoordinator.strategy`                       | Deployment strategy configuration |  RollingUpdate                                         |

### Etcd Configuration

This version of the chart includes the dependent Etcd chart in the charts/ directory.

You can find more information at:
* [https://apps.rancher.io/applications/etcd](https://apps.rancher.io/applications/etcd)

### Minio Configuration

This version of the chart includes the dependent Minio chart in the charts/ directory.

You can find more information at:
* [https://apps.rancher.io/applications/minio](https://apps.rancher.io/applications/minio)

### Kafka Configuration

This version of the chart includes the dependent apache-kafka chart in the charts/ directory.

You can find more information about apache-kafka at:
* [https://apps.rancher.io/applications/apache-kafka](https://apps.rancher.io/applications/apache-kafka)

### Milvus Live Profiling
Profiling is an effective way of understanding which parts of your application are consuming the most resources.

Continuous Profiling adds a dimension of time that allows you to understand your systems resource usage (i.e. CPU, Memory, etc.) over time and gives you the ability to locate, debug, and fix issues related to performance.

You can enable profiling with Pyroscope and you can find more information at:
* [https://pyroscope.io/docs/kubernetes-helm-chart/](https://pyroscope.io/docs/kubernetes-helm-chart/)
