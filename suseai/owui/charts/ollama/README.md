# Ollama Helm Chart
[Ollama](https://ollama.ai/), get up and running with large language models, locally.

This Chart is for deploying [Ollama](https://github.com/ollama/ollama). 

## Requirements

- Kubernetes: `>= 1.16.0-0` for **CPU only**

- Kubernetes: `>= 1.26.0-0` for **GPU** stable support (NVIDIA and AMD)

*Not all GPUs are currently supported with ollama (especially with AMD)*

## Deploying Ollama chart

To install the `ollama` chart:

Assume the release name is `ollama`:

```console
helm install ollama \
    --set 'global.imagePullSecrets[0].name'=my-pull-secrets \
    oci://dp.apps.rancher.io/charts/ollama
```

## Upgrading Ollama chart

First please read the [release notes](https://github.com/ollama/ollama/releases) of Ollama to make sure there are no
backwards incompatible changes.

Make adjustments to your values as needed, then run `helm upgrade`:

```console
helm upgrade --install ollama \
    --set 'global.imagePullSecrets[0].name'=my-pull-secrets \
    oci://dp.apps.rancher.io/charts/ollama --version=<upgradeversion>
```

## Uninstalling Ollama chart

To uninstall/delete the `ollama` deployment:

```console
helm uninstall ollama
```



## Interact with Ollama

- **Ollama documentation can be found [HERE](https://github.com/ollama/ollama/tree/main/docs)**
- Interact with RESTful API: [Ollama API](https://github.com/ollama/ollama/blob/main/docs/api.md)
- Interact with official clients libraries: [ollama-js](https://github.com/ollama/ollama-js#custom-client)
  and [ollama-python](https://github.com/ollama/ollama-python#custom-client)
- Interact with langchain: [langchain-js](https://github.com/ollama/ollama/blob/main/docs/tutorials/langchainjs.md)
  and [langchain-python](https://github.com/ollama/ollama/blob/main/docs/tutorials/langchainpy.md)

## Examples

- **It's highly recommended to run an updated version of Kubernetes for deploying ollama with GPU**

### Basic values.yaml example with GPU and two models pulled at startup

```
ollama:
  gpu:
    # -- Enable GPU integration
    enabled: true
    
    # -- GPU type: 'nvidia' or 'amd'
    type: 'nvidia'
    
    # -- Specify the number of GPU to 1
    number: 1
   
  # -- List of models to pull at container startup
  models:
    pull:
      - mistral
      - llama2
```

---

### Basic values.yaml example with Ingress

```
ollama:
  models:
    pull:
      - llama2
  
ingress:
  enabled: true
  hosts:
  - host: ollama.domain.lan
    paths:
      - path: /
        pathType: Prefix
```

- *API is now reachable at `ollama.domain.lan`*

## Upgrading from 0.X.X to 1.X.X

The version 1.X.X introduces the ability to load models in memory at startup, the values have been changed.

Please change `ollama.models` to `ollama.models.pull` to avoid errors before upgrading:

```yaml
ollama:
  models:
    - mistral
    - llama2
```

To:

```yaml
ollama:
  models:
    pull:
      - mistral
      - llama2
```

## Helm Values

- See [values.yaml](values.yaml) to see the Chart's default values.

| Key                                        | Type   | Default             | Description                                                                                                                                                                                                                                                                                                                            |
|--------------------------------------------|--------|---------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| affinity                                   | object | `{}`                | Affinity for pod assignment                                                                                                                                                                                                                                                                                                            |
| autoscaling.enabled                        | bool   | `false`             | Enable autoscaling                                                                                                                                                                                                                                                                                                                     |
| autoscaling.maxReplicas                    | int    | `100`               | Number of maximum replicas                                                                                                                                                                                                                                                                                                             |
| autoscaling.minReplicas                    | int    | `1`                 | Number of minimum replicas                                                                                                                                                                                                                                                                                                             |
| autoscaling.targetCPUUtilizationPercentage | int    | `80`                | CPU usage to target replica                                                                                                                                                                                                                                                                                                            |
| extraArgs                                  | list   | `[]`                | Additional arguments on the output Deployment definition.                                                                                                                                                                                                                                                                              |
| extraEnv                                   | list   | `[]`                | Additional environments variables on the output Deployment definition. For extra OLLAMA env, please refer to https://github.com/ollama/ollama/blob/main/envconfig/config.go                                                                                                                                                            |
| extraEnvFrom                               | list   | `[]`                | Additionl environment variables from external sources (like ConfigMap)                                                                                                                                                                                                                                                                 |
| global.imagePullSecrets | list | `[]` | Global override for container image registry pull secrets |
| global.imageRegistry | string | `""` | Global override for container image registry |
| fullnameOverride                           | string | `""`                | String to fully override template                                                                                                                                                                                                                                                                                                      |
| hostIPC                                    | bool   | `false`             | Use the host’s ipc namespace.                                                                                                                                                                                                                                                                                                          |
| hostNetwork                                | bool   | `false`             | Use the host's network namespace.                                                                                                                                                                                                                                                                                                      |
| hostPID                                    | bool   | `false`             | Use the host’s pid namespace                                                                                                                                                                                                                                                                                                           |
| image.pullPolicy                           | string | `"IfNotPresent"`    | Docker pull policy                                                                                                                                                                                                                                                                                                                     |
| image.registry | string | `"dp.apps.rancher.io"` | Image registry to use for the ollama container |
| image.repository                           | string | `"containers/ollama"`   | Image repository to use for the ollama container                                                                                                                                                                                                                                                                                                                  |
| image.tag                                  | string | `"0.5.7"`                | Image tag to use for the ollama container                                                                                                                                                                                                                                                      |
| imagePullSecrets                           | list   | `[]`                | Docker registry secret names as an array                                                                                                                                                                                                                                                                                               |
| ingress.annotations                        | object | `{}`                | Additional annotations for the Ingress resource.                                                                                                                                                                                                                                                                                       |
| ingress.className                          | string | `""`                | IngressClass that will be used to implement the Ingress (Kubernetes 1.18+)                                                                                                                                                                                                                                                             |
| ingress.enabled                            | bool   | `false`             | Enable ingress controller resource                                                                                                                                                                                                                                                                                                     |
| ingress.hosts[0].host                      | string | `"ollama.local"`    |                                                                                                                                                                                                                                                                                                                                        |
| ingress.hosts[0].paths[0].path             | string | `"/"`               |                                                                                                                                                                                                                                                                                                                                        |
| ingress.hosts[0].paths[0].pathType         | string | `"Prefix"`          |                                                                                                                                                                                                                                                                                                                                        |
| ingress.tls                                | list   | `[]`                | The tls configuration for hostnames to be covered with this ingress record.                                                                                                                                                                                                                                                            |
| initContainers                             | list   | `[]`                | Init containers to add to the pod                                                                                                                                                                                                                                                                                                      |
| knative.containerConcurrency               | int    | `0`                 | Knative service container concurrency                                                                                                                                                                                                                                                                                                  |
| knative.enabled                            | bool   | `false`             | Enable Knative integration                                                                                                                                                                                                                                                                                                             |
| knative.idleTimeoutSeconds                 | int    | `300`               | Knative service idle timeout seconds                                                                                                                                                                                                                                                                                                   |
| knative.responseStartTimeoutSeconds        | int    | `300`               | Knative service response start timeout seconds                                                                                                                                                                                                                                                                                         |
| knative.timeoutSeconds                     | int    | `300`               | Knative service timeout seconds                                                                                                                                                                                                                                                                                                        |
| lifecycle                                  | object | `{}`                | Lifecycle for pod assignment (override ollama.models startup pulling)                                                                                                                                                                                                                                                                  |
| livenessProbe.enabled                      | bool   | `true`              | Enable livenessProbe                                                                                                                                                                                                                                                                                                                   |
| livenessProbe.failureThreshold             | int    | `6`                 | Failure threshold for livenessProbe                                                                                                                                                                                                                                                                                                    |
| livenessProbe.initialDelaySeconds          | int    | `60`                | Initial delay seconds for livenessProbe                                                                                                                                                                                                                                                                                                |
| livenessProbe.path                         | string | `"/"`               | Request path for livenessProbe                                                                                                                                                                                                                                                                                                         |
| livenessProbe.periodSeconds                | int    | `10`                | Period seconds for livenessProbe                                                                                                                                                                                                                                                                                                       |
| livenessProbe.successThreshold             | int    | `1`                 | Success threshold for livenessProbe                                                                                                                                                                                                                                                                                                    |
| livenessProbe.timeoutSeconds               | int    | `5`                 | Timeout seconds for livenessProbe                                                                                                                                                                                                                                                                                                      |
| nameOverride                               | string | `""`                | String to partially override template  (will maintain the release name)                                                                                                                                                                                                                                                                |
| namespaceOverride                          | string | `""`                | String to override the namespace                                                                                                                                                                                                                                                                                                       |
| nodeSelector                               | object | `{}`                | Node labels for pod assignment.                                                                                                                                                                                                                                                                                                        |
| ollama.gpu.enabled                         | bool   | `false`             | Enable GPU integration                                                                                                                                                                                                                                                                                                                 |
| ollama.gpu.mig.devices                     | object | `{}`                | Specify the mig devices and the corresponding number                                                                                                                                                                                                                                                                                   |
| ollama.gpu.mig.enabled                     | bool   | `false`             | Enable multiple mig devices If enabled you will have to specify the mig devices If enabled is set to false this section is ignored                                                                                                                                                                                                     |
| ollama.gpu.number                          | int    | `1`                 | Specify the number of GPU If you use MIG section below then this parameter is ignored                                                                                                                                                                                                                                                  |
| ollama.gpu.nvidiaResource                  | string | `"nvidia.com/gpu"`  | only for nvidia cards; change to (example) 'nvidia.com/mig-1g.10gb' to use MIG slice                                                                                                                                                                                                                                                   |
| ollama.gpu.type                            | string | `"nvidia"`          | GPU type: 'nvidia' or 'amd' If 'ollama.gpu.enabled', default value is nvidia If set to 'amd', this will add 'rocm' suffix to image tag if 'image.tag' is not override This is due cause AMD and CPU/CUDA are different images                                                                                                          |
| ollama.insecure                            | bool   | `false`             | Add insecure flag for pulling at container startup                                                                                                                                                                                                                                                                                     |
| ollama.models.pull                         | list   | `[]`                | List of models to pull at container startup The more you add, the longer the container will take to start if models are not present pull:  - llama2  - mistral                                                                                                                                                                         |
| ollama.models.run                          | list   | `[]`                | List of models to load in memory at container startup run:  - llama2  - mistral                                                                                                                                                                                                                                                        |
| ollama.mountPath                           | string | `""`                | Override ollama-data volume mount path, default: "/root/.ollama"                                                                                                                                                                                                                                                                       |
| persistentVolume.accessModes               | list   | `["ReadWriteOnce"]` | Ollama server data Persistent Volume access modes Must match those of existing PV or dynamic provisioner Ref: http://kubernetes.io/docs/user-guide/persistent-volumes/                                                                                                                                                                 |
| persistentVolume.annotations               | object | `{}`                | Ollama server data Persistent Volume annotations                                                                                                                                                                                                                                                                                       |
| persistentVolume.enabled                   | bool   | `false`             | Enable persistence using PVC                                                                                                                                                                                                                                                                                                           |
| persistentVolume.existingClaim             | string | `""`                | If you'd like to bring your own PVC for persisting Ollama state, pass the name of the created + ready PVC here. If set, this Chart will not create the default PVC. Requires server.persistentVolume.enabled: true                                                                                                                     |
| persistentVolume.size                      | string | `"30Gi"`            | Ollama server data Persistent Volume size                                                                                                                                                                                                                                                                                              |
| persistentVolume.storageClass              | string | `""`                | Ollama server data Persistent Volume Storage Class If defined, storageClassName: <storageClass> If set to "-", storageClassName: "", which disables dynamic provisioning If undefined (the default) or set to null, no storageClassName spec is set, choosing the default provisioner.  (gp2 on AWS, standard on GKE, AWS & OpenStack) |
| persistentVolume.subPath                   | string | `""`                | Subdirectory of Ollama server data Persistent Volume to mount Useful if the volume's root directory is not empty                                                                                                                                                                                                                       |
| persistentVolume.volumeMode                | string | `""`                | Ollama server data Persistent Volume Binding Mode If defined, volumeMode: <volumeMode> If empty (the default) or set to null, no volumeBindingMode spec is set, choosing the default mode.                                                                                                                                             |
| persistentVolume.volumeName                | string | `""`                | Pre-existing PV to attach this claim to Useful if a CSI auto-provisions a PV for you and you want to always reference the PV moving forward                                                                                                                                                                                            |
| podAnnotations                             | object | `{}`                | Map of annotations to add to the pods                                                                                                                                                                                                                                                                                                  |
| podLabels                                  | object | `{}`                | Map of labels to add to the pods                                                                                                                                                                                                                                                                                                       |
| podSecurityContext                         | object | `{}`                | Pod Security Context                                                                                                                                                                                                                                                                                                                   |
| readinessProbe.enabled                     | bool   | `true`              | Enable readinessProbe                                                                                                                                                                                                                                                                                                                  |
| readinessProbe.failureThreshold            | int    | `6`                 | Failure threshold for readinessProbe                                                                                                                                                                                                                                                                                                   |
| readinessProbe.initialDelaySeconds         | int    | `30`                | Initial delay seconds for readinessProbe                                                                                                                                                                                                                                                                                               |
| readinessProbe.path                        | string | `"/"`               | Request path for readinessProbe                                                                                                                                                                                                                                                                                                        |
| readinessProbe.periodSeconds               | int    | `5`                 | Period seconds for readinessProbe                                                                                                                                                                                                                                                                                                      |
| readinessProbe.successThreshold            | int    | `1`                 | Success threshold for readinessProbe                                                                                                                                                                                                                                                                                                   |
| readinessProbe.timeoutSeconds              | int    | `3`                 | Timeout seconds for readinessProbe                                                                                                                                                                                                                                                                                                     |
| replicaCount                               | int    | `1`                 | Number of replicas                                                                                                                                                                                                                                                                                                                     |
| resources.limits                           | object | `{}`                | Pod limit                                                                                                                                                                                                                                                                                                                              |
| resources.requests                         | object | `{}`                | Pod requests                                                                                                                                                                                                                                                                                                                           |
| runtimeClassName                           | string | `""`                | Specify runtime class                                                                                                                                                                                                                                                                                                                  |
| securityContext                            | object | `{}`                | Container Security Context                                                                                                                                                                                                                                                                                                             |
| service.annotations                        | object | `{}`                | Annotations to add to the service                                                                                                                                                                                                                                                                                                      |
| service.loadBalancerIP                     | string | `nil`               | Load Balancer IP address                                                                                                                                                                                                                                                                                                               |
| service.nodePort                           | int    | `31434`             | Service node port when service type is 'NodePort'                                                                                                                                                                                                                                                                                      |
| service.port                               | int    | `11434`             | Service port                                                                                                                                                                                                                                                                                                                           |
| service.type                               | string | `"ClusterIP"`       | Service type                                                                                                                                                                                                                                                                                                                           |
| serviceAccount.annotations                 | object | `{}`                | Annotations to add to the service account                                                                                                                                                                                                                                                                                              |
| serviceAccount.automount                   | bool   | `true`              | Automatically mount a ServiceAccount's API credentials?                                                                                                                                                                                                                                                                                |
| serviceAccount.create                      | bool   | `true`              | Specifies whether a service account should be created                                                                                                                                                                                                                                                                                  |
| serviceAccount.name                        | string | `""`                | The name of the service account to use. If not set and create is true, a name is generated using the fullname template                                                                                                                                                                                                                 |
| tolerations                                | list   | `[]`                | Tolerations for pod assignment                                                                                                                                                                                                                                                                                                         |
| topologySpreadConstraints                  | object | `{}`                | Topology Spread Constraints for pod assignment                                                                                                                                                                                                                                                                                         |
| updateStrategy.type                        | string | `"Recreate"`        | Deployment strategy can be "Recreate" or "RollingUpdate". Default is Recreate                                                                                                                                                                                                                                                          |
| volumeMounts                               | list   | `[]`                | Additional volumeMounts on the output Deployment definition.                                                                                                                                                                                                                                                                           |
| volumes                                    | list   | `[]`                | Additional volumes on the output Deployment definition.                                                                                                                                                                                                                                                                                |

----------------------------------------------
