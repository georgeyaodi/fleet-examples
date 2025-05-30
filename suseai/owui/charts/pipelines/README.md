# pipelines

![Version: 0.2.0](https://img.shields.io/badge/Version-0.2.0-informational?style=flat-square) ![AppVersion: alpha](https://img.shields.io/badge/AppVersion-alpha-informational?style=flat-square)

Pipelines: UI-Agnostic OpenAI API Plugin Framework

**Homepage:** <https://github.com/open-webui/pipelines>

## Source Code

* <https://github.com/open-webui/helm-charts>
* <https://github.com/open-webui/pipelines/pkgs/container/pipelines>

## Installing

Before you can install, you need to add the `open-webui` repo to [Helm](https://helm.sh)

```shell
helm repo add open-webui https://helm.openwebui.com/
helm repo update
```

Now you can install the chart:

```shell
helm upgrade --install open-webui open-webui/pipelines
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity for pod assignment |
| annotations | object | `{}` |  |
| clusterDomain | string | `"cluster.local"` | Value of cluster domain |
| extraEnvVars | list | `[{"name":"PIPELINES_URLS","value":"https://github.com/open-webui/pipelines/blob/main/examples/filters/detoxify_filter_pipeline.py"}]` | Additional environments variables on the output Deployment definition. These are used to pull initial Pipeline files, and help configure Pipelines with required values (e.g. Langfuse API keys) |
| extraEnvVars[0] | object | `{"name":"PIPELINES_URLS","value":"https://github.com/open-webui/pipelines/blob/main/examples/filters/detoxify_filter_pipeline.py"}` | Example pipeline to pull and load on deployment startup, see current pipelines here: https://github.com/open-webui/pipelines/blob/main/examples |
| extraResources | list | `[]` | Extra resources to deploy with Open WebUI Pipelines |
| image.pullPolicy | string | `"Always"` |  |
| image.repository | string | `"ghcr.io/open-webui/pipelines"` |  |
| image.tag | string | `"main"` |  |
| imagePullSecrets | list | `[]` | Configure imagePullSecrets to use private registry ref: <https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry> |
| ingress.annotations | object | `{}` | Use appropriate annotations for your Ingress controller, e.g., for NGINX: nginx.ingress.kubernetes.io/rewrite-target: / |
| ingress.class | string | `""` |  |
| ingress.enabled | bool | `true` |  |
| ingress.existingSecret | string | `""` |  |
| ingress.host | string | `""` |  |
| ingress.tls | bool | `false` |  |
| nameOverride | string | `""` |  |
| namespaceOverride | string | `""` |  |
| nodeSelector | object | `{}` | Node labels for pod assignment. |
| persistence.accessModes | list | `["ReadWriteOnce"]` | If using multiple replicas, you must update accessModes to ReadWriteMany |
| persistence.annotations | object | `{}` |  |
| persistence.enabled | bool | `true` |  |
| persistence.existingClaim | string | `""` |  |
| persistence.selector | object | `{}` |  |
| persistence.size | string | `"2Gi"` |  |
| persistence.storageClass | string | `""` |  |
| podAnnotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| service.annotations | object | `{}` |  |
| service.containerPort | int | `9099` |  |
| service.labels | object | `{}` |  |
| service.loadBalancerClass | string | `""` |  |
| service.nodePort | string | `""` |  |
| service.port | int | `9099` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.automountServiceAccountToken | bool | `false` |  |
| serviceAccount.enable | bool | `true` |  |
| tolerations | list | `[]` | Tolerations for pod assignment |
| volumeMounts | list | `[]` | Configure container volume mounts |
| volumes | list | `[]` | Configure pod volumes |

----------------------------------------------

Autogenerated from chart metadata using [helm-docs](https://github.com/norwoodj/helm-docs/).
