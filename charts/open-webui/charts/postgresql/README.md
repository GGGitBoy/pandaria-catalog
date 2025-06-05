# PostgreSQL Helm Chart

> [PostgreSQL](https://www.postgresql.org) is an advanced object-relational database management system that supports an extended subset of the SQL standard, including transactions, foreign keys, subqueries, triggers, user-defined types and functions.

## Introduction

This Helm chart bootstraps a [PostgreSQL](https:///www.postgresql.org) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Quick Start

```console
helm install my-release oci://dp.apps.rancher.io/charts/postgresql
```

### Prerequisites

* Helm 3.8.0 or later.
* Kubernetes 1.24 or later.
* PV provisioner support in the underlying infrastructure.

## Install Chart

To install the Helm chart with the release name *my-release*:

```console
helm install my-release \
    --set 'global.imagePullSecrets[0].name'=my-pull-secrets \
    oci://dp.apps.rancher.io/charts/postgresql \
```

This deploys the application to the Kubernetes cluster using the default configuration provided by the Helm chart.

> NOTE: You can follow [these steps](https://cloud.google.com/artifact-registry/docs/access-control#pullsecrets)
> to create and setup the image pull secrets, if you don't have them already.

## Uninstall Chart

To uninstall the Helm chart with the release name *my-release*:

```console
helm uninstall my-release
```

This removes all the Kubernetes components associated to the Helm chart

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| auth.database | string | `""` | PostgreSQL database to create. If empty, the database will not be created |
| auth.existingSecret | string | `""` | Name of a secret containing the secret for the PostgreSQL passwords (if set, `auth.password`, `auth.postgresPassword` and `auth.replicationPassword` will be ignored) |
| auth.password | string | `""` | PostgreSQL password for the user to create |
| auth.passwordKey | string | `"password"` | Password key in the secret @default `password` |
| auth.postgresPassword | string | `""` | PostgreSQL password for the superuser |
| auth.postgresPasswordKey | string | `"postgresPassword"` | PostgreSQL `postgres` user password key in the secret @default `postgresPassword` |
| auth.postgresUsername | string | `"postgres"` | PostgreSQL username for the superuser |
| auth.replicationPassword | string | `""` | Replication password |
| auth.replicationPasswordKey | string | `"replicationPassword"` | Replication user password key in the secret @default `replicationPassword` |
| auth.replicationUsername | string | `"replication"` | Replication username |
| auth.username | string | `""` | PostgreSQL username for the user to create. If empty, the user will not be created |
| clusterDomain | string | `"cluster.local"` | Kubernetes cluster domain name |
| commonAnnotations | object | `{}` | Annotations to add to all deployed objects |
| commonLabels | object | `{}` | Labels to add to all deployed objects |
| configMap | object | See `values.yaml` | ConfigMaps to deploy |
| configMap.* | string | `nil` | Custom configuration file to include, templates are allowed both in the config map name and contents |
| configMap.enabled | string | `"{{ and (not .Values.existingConfigMap) (or .Values.configuration .Values.hbaConfiguration .Values.identConfiguration) }}"` | Create a config map for PostgreSQL configuration |
| configuration | string | `""` | Extra configurations to add to the PostgreSQL configuration file. Can be defined as a string, a key-value map, or an array of entries. See: https://www.postgresql.org/docs/current/runtime-config.html |
| configurationFile | string | `"postgresql.conf"` | Configuration file name in the config map |
| containerPorts.* | int32 | `nil` | Custom port number to expose in the PostgreSQL containers |
| containerPorts.metrics | int32 | `9187` | Port number where metrics will be exposed to |
| containerPorts.postgresql | int32 | `5432` | PostgreSQL port number for client connections |
| containerSecurityContext.allowPrivilegeEscalation | bool | `false` | Allow privilege escalation within containers |
| containerSecurityContext.enabled | bool | `true` | Enable container security context |
| containerSecurityContext.runAsNonRoot | bool | `true` | Run containers as a non-root user |
| containerSecurityContext.runAsUser | int | `1000` | Which user ID to run the container as |
| existingConfigMap | string | `""` | Name of an existing config map for extra configurations to add to the PostgreSQL configuration file |
| extraManifests | list | `[]` | Additional Kubernetes manifests to include in the chart |
| fullnameOverride | string | `""` | Override the resource name |
| global.imagePullSecrets | list | `[]` | Global override for container image registry pull secrets |
| global.imageRegistry | string | `""` | Global override for container image registry |
| global.storageClassName | string | `""` | Global override for the storage class |
| hbaConfiguration | string | `""` | Extra configurations to add to the PostgreSQL host-based authentication (HBA) file. Can be defined as a string, a key-value map, or an array of entries. See: https://www.postgresql.org/docs/current/auth-pg-hba-conf.html |
| hbaConfigurationFile | string | `"pg_hba.conf"` | Configuration file name for host-based authentication (HBA) in the config map |
| headlessService.* | string | `nil` | Custom attributes for the PostgreSQL headless service (see [`ServiceSpec` API reference](https://kubernetes.io/docs/reference/kubernetes-api/service-resources/service-v1/#ServiceSpec)) |
| headlessService.annotations | object | `{}` | Custom annotations to add to the headless service for PostgreSQL |
| headlessService.clusterIP | string | `"None"` |  |
| headlessService.ports.* | int32 | `nil` | Headless service port override for custom PostgreSQL ports specified in `containerPorts.*` |
| headlessService.ports.postgresql | int32 | `""` | Headless service port override for PostgreSQL client connections |
| headlessService.publishNotReadyAddresses | bool | `true` | Disregard indications of ready/not-ready The primary use case for setting this field is for a StatefulSet's Headless Service to propagate SRV DNS records for its Pods for the purpose of peer discovery |
| headlessService.type | string | `"ClusterIP"` | PostgreSQL headless service type |
| identConfiguration | string | `""` | Extra configurations to add to the user name mapping (ident) file. Can be defined as a string, a key-value map, or an array of entries. See: https://www.postgresql.org/docs/current/auth-username-maps.html |
| identConfigurationFile | string | `"pg_ident.conf"` | Configuration file name for user name mapping (ident) in the config map |
| images.metrics.digest | string | `""` | Image digest to use for the PostgreSQL container (if set, `images.metrics.tag` will be ignored) |
| images.metrics.pullPolicy | string | `"IfNotPresent"` | Image pull policy to use for the PostgreSQL container |
| images.metrics.registry | string | `"dp.apps.rancher.io"` | Image registry to use for the PostgreSQL Server Exporter container |
| images.metrics.repository | string | `"containers/postgres-exporter"` | Image repository to use for the PostgreSQL Server Exporter container |
| images.metrics.tag | string | `"0"` | Image tag to use for the PostgreSQL container |
| images.postgresql.digest | string | `""` | Image digest to use for the PostgreSQL container (if set, `images.postgresql.tag` will be ignored) |
| images.postgresql.pullPolicy | string | `"IfNotPresent"` | Image pull policy to use for the PostgreSQL container |
| images.postgresql.registry | string | `"dp.apps.rancher.io"` | Image registry to use for the PostgreSQL container |
| images.postgresql.repository | string | `"containers/postgresql"` | Image repository to use for the PostgreSQL container |
| images.postgresql.tag | string | `"17.4"` | Image tag to use for the PostgreSQL container |
| images.volume-permissions.digest | string | `""` | Image digest to use for the volume permissions init container (if set, `images.volume-permissions.tag` will be ignored) |
| images.volume-permissions.pullPolicy | string | `"IfNotPresent"` | Image pull policy to use for the volume-permissions container |
| images.volume-permissions.registry | string | `"dp.apps.rancher.io"` | Image registry to use for the volume permissions init container |
| images.volume-permissions.repository | string | `"containers/bci-busybox"` | Image pository to use for the volume permissions init container |
| images.volume-permissions.tag | string | `"15.6"` | Image tag to use for the volume permissions init container |
| metrics.annotations | object | See `values.yaml` | Annotations to add to all pods that expose metrics |
| metrics.enabled | bool | `false` | Expose PostgreSQL metrics |
| metrics.prometheusRule.configuration | object | `{}` | Content of the Prometheus rule file See https://prometheus.io/docs/prometheus/latest/configuration/recording_rules/ |
| metrics.prometheusRule.enabled | bool | `false` | Create a PrometheusRule resource (also requires `metrics.enabled` to be enabled) |
| metrics.prometheusRule.labels | object | `{}` | Additional labels that will be added to the PrometheusRule resource |
| metrics.prometheusRule.namespace | string | `""` | Namespace for the PrometheusRule resource (defaults to the release namespace) |
| metrics.service.* | string | `nil` | Custom attributes for the service (see [`ServiceSpec` API reference](https://kubernetes.io/docs/reference/kubernetes-api/service-resources/service-v1/#ServiceSpec)) |
| metrics.service.annotations | object | `{}` | Custom annotations to add to the service for postgres-exporter |
| metrics.service.enabled | bool | `true` | Create a service for postgres-exporter (apart from the headless service) |
| metrics.service.nodePorts.* | int32 | `nil` | Service nodePort override for custom ports specified in `containerPorts.*` |
| metrics.service.nodePorts.metrics | int32 | `""` | Service nodePort override for postgres-exporter metrics connections |
| metrics.service.ports.* | int32 | `nil` | Service port override for custom ports specified in `containerPorts.*` |
| metrics.service.ports.metrics | int32 | `""` | Service port override for postgres-exporter metrics connections |
| metrics.service.type | string | `"ClusterIP"` | Service type |
| nameOverride | string | `""` | Override the resource name prefix (will keep the release name) |
| networkPolicy.allowExternalConnections | bool | `true` | Allow all external connections from and to the pods |
| networkPolicy.egress.allowExternalConnections | bool | `true` | Allow all external egress connections from the pods (requires also `networkPolicy.allowExternalConnections`) |
| networkPolicy.egress.enabled | bool | `true` | Create an egress network policy (requires also `networkPolicy.enabled`) |
| networkPolicy.egress.extraRules | list | `[]` | Custom additional egress rules to enable in the NetworkPolicy resource |
| networkPolicy.egress.namespaceLabels | object | `{}` | List of namespace labels for which to allow egress connections, when external connections are disallowed |
| networkPolicy.egress.podLabels | object | `{}` | List of pod labels for which to allow egress connections, when external connections are disallowed |
| networkPolicy.egress.ports.* | int32 | `nil` | Network policy port override for custom ports specified in `containerPorts.*` for egress connections |
| networkPolicy.egress.ports.client | int32 | `""` | Network policy port override for PostgreSQL client connections for egress connections |
| networkPolicy.egress.ports.peer | int32 | `""` | Network policy port override for PostgreSQL peer connections for egress connections |
| networkPolicy.enabled | bool | `false` | Create a NetworkPolicy resource |
| networkPolicy.ingress.allowExternalConnections | bool | `true` | Allow all external ingress connections to the pods (requires also `networkPolicy.allowExternalConnections`) |
| networkPolicy.ingress.enabled | bool | `true` | Create an ingress network policy (requires also `networkPolicy.enabled`) |
| networkPolicy.ingress.extraRules | list | `[]` | Custom additional ingress rules to enable in the NetworkPolicy resource |
| networkPolicy.ingress.namespaceLabels | object | `{}` | List of namespace labels for which to allow ingress connections, when external connections are disallowed |
| networkPolicy.ingress.podLabels | object | `{}` | List of pod labels for which to allow ingress connections, when external connections are disallowed |
| networkPolicy.ingress.ports.* | int32 | `nil` | Network policy port override for custom ports specified in `containerPorts.*` for ingress connections |
| networkPolicy.ingress.ports.client | int32 | `""` | Network policy port override for PostgreSQL client connections for ingress connections |
| networkPolicy.ingress.ports.peer | int32 | `""` | Network policy port override for PostgreSQL peer connections for ingress connections |
| nodeCount | int | `1` | Desired number of PostgreSQL nodes to deploy (counting the PostgreSQL primary node) |
| persistence.accessModes | list | `["ReadWriteOnce"]` | Persistent volume access modes |
| persistence.annotations | object | `{}` | Custom annotations to add to the persistent volume claims used by PostgreSQL pods |
| persistence.enabled | bool | `true` | Enable persistent volume claims for PostgreSQL pods |
| persistence.existingClaim | string | `""` | Name of an existing PersistentVolumeClaim to use by PostgreSQL pods |
| persistence.labels | object | `{}` | Custom labels to add to the persistent volume claims used by PostgreSQL pods |
| persistence.resources.requests.storage | string | `"8Gi"` | Size of the persistent volume claim to create for PostgreSQL pods |
| persistence.storageClassName | string | `""` | Storage class name to use for the PostgreSQL persistent volume claim |
| podDisruptionBudget.enabled | bool | `false` | Create a pod disruption budget |
| podDisruptionBudget.maxUnavailable | string | `""` | Number of pods from that can be unavailable after the eviction, this option is mutually exclusive with minAvailable |
| podDisruptionBudget.minAvailable | string | `""` | Number of pods from that set that must still be available after the eviction, this option is mutually exclusive with maxUnavailable |
| podSecurityContext.enabled | bool | `true` | Enable pod security context |
| podTemplates.* | string | `nil` | Custom attributes for the pods in the PostgreSQL PodTemplate (see [`PodSpec` API reference](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#PodSpec)) |
| podTemplates.annotations | object | See `values.yaml` | Annotations to add to all pods in the PostgreSQL StatefulSet's PodTemplate |
| podTemplates.containers | object | See `values.yaml` | Containers to deploy in the PostgreSQL PodTemplate Each field has the container name as key, and a YAML object template with the values; you must set `enabled: true` to enable it |
| podTemplates.containers.metrics.* | string | `nil` | Custom attributes for the postgres-exporter container (see [`Container` API spec](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#Container)) |
| podTemplates.containers.metrics.args | list | `[]` | Arguments override for the postgres-exporter container entrypoint |
| podTemplates.containers.metrics.command | string | `""` | Entrypoint override for the postgres-exporter container |
| podTemplates.containers.metrics.enabled | string | Same value as `metrics.enabled` | Enable the postgres-exporter container in the PostgreSQL PodTemplate |
| podTemplates.containers.metrics.env | object | See `values.yaml` | Object with the environment variables templates to use in the postgres-exporter container, the values can be specified as an object or a string; when using objects you must also set `enabled: true` to enable it |
| podTemplates.containers.metrics.envFrom | list | `[]` | List of sources from which to populate environment variables to the postgres-exporter container (e.g. a ConfigMaps or a Secret) |
| podTemplates.containers.metrics.image | string | `""` | Image override for the postgres-exporter container (if set, `images.metrics.{name,tag,digest}` values will be ignored for this container) |
| podTemplates.containers.metrics.imagePullPolicy | string | `""` | Image pull policy override for the postgres-exporter container (if set `images.metrics.pullPolicy` values will be ignored for this container) |
| podTemplates.containers.metrics.livenessProbe.enabled | bool | `true` | Enable liveness probe for postgres-exporter |
| podTemplates.containers.metrics.livenessProbe.failureThreshold | int | `5` | Minimum consecutive failures for the postgres-exporter liveness probe to be considered failed after having succeeded |
| podTemplates.containers.metrics.livenessProbe.initialDelaySeconds | int | `10` | Number of seconds after the postgres-exporter container has started before liveness probes are initiated |
| podTemplates.containers.metrics.livenessProbe.periodSeconds | int | `10` | How often (in seconds) to perform the postgres-exporter liveness probe |
| podTemplates.containers.metrics.livenessProbe.successThreshold | int | `1` | Minimum consecutive successes for the postgres-exporter liveness probe to be considered successful after having failed |
| podTemplates.containers.metrics.livenessProbe.tcpSocket | object | See `values.yaml` | Port number used to check if the postgres-exporter service is alive |
| podTemplates.containers.metrics.livenessProbe.timeoutSeconds | int | `5` | Number of seconds after which the postgres-exporter liveness probe times out |
| podTemplates.containers.metrics.ports | object | `{}` | Ports override for the postgres-exporter container (if set, `containerPorts.*` values will be ignored for this container) |
| podTemplates.containers.metrics.readinessProbe.enabled | bool | `true` | Enable readiness probe for postgres-exporter |
| podTemplates.containers.metrics.readinessProbe.failureThreshold | int | `5` | Minimum consecutive failures for the postgres-exporter readiness probe to be considered failed after having succeeded |
| podTemplates.containers.metrics.readinessProbe.httpGet | object | See `values.yaml` | HTTP endpoint used to check if the postgres-exporter service is ready |
| podTemplates.containers.metrics.readinessProbe.initialDelaySeconds | int | `10` | Number of seconds after the postgres-exporter container has started before readiness probes are initiated |
| podTemplates.containers.metrics.readinessProbe.periodSeconds | int | `10` | How often (in seconds) to perform the postgres-exporter readiness probe |
| podTemplates.containers.metrics.readinessProbe.successThreshold | int | `1` | Minimum consecutive successes for the postgres-exporter readiness probe to be considered successful after having failed |
| podTemplates.containers.metrics.readinessProbe.timeoutSeconds | int | `5` | Number of seconds after which the postgres-exporter readiness probe times out |
| podTemplates.containers.metrics.resources | object | `{}` | Custom resource requirements for the postgres-exporter container |
| podTemplates.containers.metrics.securityContext | object | `{}` | Security context override for the postgres-exporter container (if set, `containerSecurityContext.*` values will be ignored for this container) |
| podTemplates.containers.metrics.startupProbe.enabled | bool | `false` | Enable startup probe for postgres-exporter |
| podTemplates.containers.metrics.startupProbe.failureThreshold | int | `10` | Minimum consecutive failures for the postgres-exporter startup probe to be considered failed after having succeeded |
| podTemplates.containers.metrics.startupProbe.initialDelaySeconds | int | `0` | Number of seconds after the postgres-exporter container has started before startup probes are initiated |
| podTemplates.containers.metrics.startupProbe.periodSeconds | int | `10` | How often (in seconds) to perform the postgres-exporter startup probe |
| podTemplates.containers.metrics.startupProbe.successThreshold | int | `1` | Minimum consecutive successes for the postgres-exporter startup probe to be considered successful after having failed |
| podTemplates.containers.metrics.startupProbe.tcpSocket | object | See `values.yaml` | Port number used to check if the postgres-exporter service has been started |
| podTemplates.containers.metrics.startupProbe.timeoutSeconds | int | `5` | Number of seconds after which the postgres-exporter startup probe times out |
| podTemplates.containers.metrics.volumeMounts | object | See `values.yaml` | Volume mount templates for the postgres-exporter container, templates are allowed in all fields Each field has the volume mount name as key, and a YAML string template with the values; you must set `enabled: true` to enable it |
| podTemplates.containers.postgresql.* | string | `nil` | Custom attributes for the PostgreSQL container (see [`Container` API spec](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#Container)) |
| podTemplates.containers.postgresql.args | list | `[]` | Arguments override for the PostgreSQL container entrypoint |
| podTemplates.containers.postgresql.command | list | See `values.yaml` | Entrypoint override for the PostgreSQL container |
| podTemplates.containers.postgresql.enabled | bool | `true` | Enable the PostgreSQL container in the PodTemplate |
| podTemplates.containers.postgresql.env | object | See `values.yaml` | Object with the environment variables templates to use in the PostgreSQL container, the values can be specified as an object or a string; when using objects you must also set `enabled: true` to enable it |
| podTemplates.containers.postgresql.envFrom | list | `[]` | List of sources from which to populate environment variables to the PostgreSQL container (e.g. a ConfigMaps or a Secret) |
| podTemplates.containers.postgresql.image | string | `""` | Image override for the PostgreSQL container (if set, `images.postgresql.{name,tag,digest}` values will be ignored for this container) |
| podTemplates.containers.postgresql.imagePullPolicy | string | `""` | Image pull policy override for the PostgreSQL container (if set `images.postgresql.pullPolicy` values will be ignored for this container) |
| podTemplates.containers.postgresql.livenessProbe.enabled | bool | `true` | Enable liveness probe for PostgreSQL |
| podTemplates.containers.postgresql.livenessProbe.exec | object | See `values.yaml` | Command to execute for the PostgreSQL startup probe |
| podTemplates.containers.postgresql.livenessProbe.failureThreshold | int | `5` | Minimum consecutive failures for the PostgreSQL liveness probe to be considered failed after having succeeded |
| podTemplates.containers.postgresql.livenessProbe.initialDelaySeconds | int | `10` | Number of seconds after the PostgreSQL container has started before liveness probes are initiated |
| podTemplates.containers.postgresql.livenessProbe.periodSeconds | int | `10` | How often (in seconds) to perform the PostgreSQL liveness probe |
| podTemplates.containers.postgresql.livenessProbe.successThreshold | int | `1` | Minimum consecutive successes for the PostgreSQL liveness probe to be considered successful after having failed |
| podTemplates.containers.postgresql.livenessProbe.timeoutSeconds | int | `5` | Number of seconds after which the PostgreSQL liveness probe times out |
| podTemplates.containers.postgresql.ports | object | `{}` | Ports override for the PostgreSQL container (if set, `containerPorts.*` values will be ignored for this container) |
| podTemplates.containers.postgresql.readinessProbe.enabled | bool | `true` | Enable readiness probe for PostgreSQL |
| podTemplates.containers.postgresql.readinessProbe.exec | object | See `values.yaml` | Command to execute for the PostgreSQL startup probe |
| podTemplates.containers.postgresql.readinessProbe.failureThreshold | int | `5` | Minimum consecutive failures for the PostgreSQL readiness probe to be considered failed after having succeeded |
| podTemplates.containers.postgresql.readinessProbe.initialDelaySeconds | int | `10` | Number of seconds after the PostgreSQL container has started before readiness probes are initiated |
| podTemplates.containers.postgresql.readinessProbe.periodSeconds | int | `10` | How often (in seconds) to perform the PostgreSQL readiness probe |
| podTemplates.containers.postgresql.readinessProbe.successThreshold | int | `1` | Minimum consecutive successes for the PostgreSQL readiness probe to be considered successful after having failed |
| podTemplates.containers.postgresql.readinessProbe.timeoutSeconds | int | `5` | Number of seconds after which the PostgreSQL readiness probe times out |
| podTemplates.containers.postgresql.resources | object | `{}` | Custom resource requirements for the PostgreSQL container |
| podTemplates.containers.postgresql.securityContext | object | `{}` | Security context override for the PostgreSQL container (if set, `containerSecurityContext.*` values will be ignored for this container) |
| podTemplates.containers.postgresql.startupProbe.enabled | bool | `false` | Enable startup probe for PostgreSQL |
| podTemplates.containers.postgresql.startupProbe.failureThreshold | int | `10` | Minimum consecutive failures for the PostgreSQL startup probe to be considered failed after having succeeded |
| podTemplates.containers.postgresql.startupProbe.initialDelaySeconds | int | `0` | Number of seconds after the PostgreSQL container has started before startup probes are initiated |
| podTemplates.containers.postgresql.startupProbe.periodSeconds | int | `10` | How often (in seconds) to perform the PostgreSQL startup probe |
| podTemplates.containers.postgresql.startupProbe.successThreshold | int | `1` | Minimum consecutive successes for the PostgreSQL startup probe to be considered successful after having failed |
| podTemplates.containers.postgresql.startupProbe.tcpSocket | object | See `values.yaml` | Port number used to check if the PostgreSQL service is alive |
| podTemplates.containers.postgresql.startupProbe.timeoutSeconds | int | `5` | Number of seconds after which the PostgreSQL startup probe times out |
| podTemplates.containers.postgresql.volumeMounts | object | See `values.yaml` | Volume mount templates for the PostgreSQL container, templates are allowed in all fields Each field has the volume mount name as key, and a YAML string template with the values; you must set `enabled: true` to enable it |
| podTemplates.imagePullSecrets | list | `[]` | Custom pull secrets for the PostgreSQL container in the PodTemplate |
| podTemplates.initContainers | object | See `values.yaml` | Init containers to deploy in the PostgreSQL PodTemplate Each field has the init container name as key, and a YAML object template with the values; you must set `enabled: true` to enable it |
| podTemplates.initContainers.volume-permissions.* | string | `nil` | Custom attributes for the PostgreSQL volume-permissions init container (see [`Container` API spec](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#Container)) |
| podTemplates.initContainers.volume-permissions.args | list | `[]` | Arguments override for the PostgreSQL volume-permissions init container entrypoint |
| podTemplates.initContainers.volume-permissions.command | list | See `values.yaml` | Entrypoint override for the PostgreSQL volume-permissions container |
| podTemplates.initContainers.volume-permissions.enabled | bool | `false` | Enable the volume-permissions init container in the PostgreSQL PodTemplate |
| podTemplates.initContainers.volume-permissions.env | object | No environment variables are set | Object with the environment variables templates to use in the PostgreSQL volume-permissions init container, the values can be specified as an object or a string; when using objects you must also set `enabled: true` to enable it |
| podTemplates.initContainers.volume-permissions.envFrom | list | `[]` | List of sources from which to populate environment variables to the PostgreSQL volume-permissions init container (e.g. a ConfigMaps or a Secret) |
| podTemplates.initContainers.volume-permissions.image | string | `""` | Image override for the PostgreSQL volume-permissions init container (if set, `images.volume-permissions.{name,tag,digest}` values will be ignored for this container) |
| podTemplates.initContainers.volume-permissions.imagePullPolicy | string | `""` | Image pull policy override for the PostgreSQL volume-permissions init container (if set `images.volume-permissions.pullPolicy` values will be ignored for this container) |
| podTemplates.initContainers.volume-permissions.resources | object | `{}` | PostgreSQL init-containers resource requirements |
| podTemplates.initContainers.volume-permissions.securityContext | object | See `values.yaml` | Security context override for the PostgreSQL volume-permissions init container (if set, `containerSecurityContext.*` values will be ignored for this container) |
| podTemplates.initContainers.volume-permissions.volumeMounts | object | See `values.yaml` | Custom volume mounts for the PostgreSQL volume-permissions init container, templates are allowed in all fields Each field has the volume mount name as key, and a YAML string template with the values; you must set `enabled: true` to enable it |
| podTemplates.labels | object | `{}` | Labels to add to all pods in the PostgreSQL StatefulSet's PodTemplate |
| podTemplates.securityContext | object | `{}` | Security context override for the pods in the PostgreSQL PodTemplate (if set, `podSecurityContext.*` values will be ignored) |
| podTemplates.serviceAccountName | string | `""` | Service account name override for the pods in the PostgreSQL PodTemplate (if set, `serviceAccount.name` will be ignored) |
| podTemplates.volumes | object | See `values.yaml` | Volume templates for the PostgreSQL PodTemplate, templates are allowed in all fields Each field has the volume name as key, and a YAML string template with the values; you must set `enabled: true` to enable it |
| secret | object | See `values.yaml` | Secrets to deploy |
| secret.* | string | `nil` | Custom secret to include, templates are allowed both in the secret name and contents |
| secret.enabled | string | `true` if authentication is enabled without existing secret, `false` otherwise | Create a secret for PostgreSQL credentials |
| service.* | string | `nil` | Custom attributes for the PostgreSQL service (see [`ServiceSpec` API reference](https://kubernetes.io/docs/reference/kubernetes-api/service-resources/service-v1/#ServiceSpec)) |
| service.annotations | object | `{}` | Custom annotations to add to the service for PostgreSQL |
| service.enabled | bool | `true` | Create a service for PostgreSQL (apart from the headless service) |
| service.nodePorts.* | int32 | `nil` | Service nodePort override for custom PostgreSQL ports specified in `containerPorts.*` |
| service.nodePorts.postgresql | int32 | `""` | Service nodePort override for PostgreSQL client connections |
| service.ports.* | int32 | `nil` | Service port override for custom PostgreSQL ports specified in `containerPorts.*` |
| service.ports.postgresql | int32 | `""` | Service port override for PostgreSQL client connections |
| service.type | string | `"ClusterIP"` | PostgreSQL service type |
| serviceAccount.annotations | object | `{}` | Add custom annotations to the ServiceAccount |
| serviceAccount.automountServiceAccountToken | bool | `true` | Whether pods running as this service account should have an API token automatically mounted |
| serviceAccount.enabled | bool | `false` | Create or use an existing service account |
| serviceAccount.imagePullSecrets | list | `[]` | List of references to secrets in the same namespace to use for pulling any images in pods that reference this ServiceAccount |
| serviceAccount.labels | object | `{}` | Add custom labels to the ServiceAccount |
| serviceAccount.name | string | `""` | Name of the ServiceAccount to use |
| serviceAccount.secrets | list | `[]` | List of secrets in the same namespace that pods running using this ServiceAccount are allowed to use |
| statefulset.* | string | `nil` | Custom attributes for the PostgreSQL StatefulSet (see [`StatefulSetSpec` API reference](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/stateful-set-v1/#StatefulSetSpec)) |
| statefulset.enabled | bool | `true` | Enable the StatefulSet template for PostgreSQL standalone mode |
| statefulset.persistentVolumeClaimRetentionPolicy | object | `{}` | Lifecycle of the persistent volume claims created from PostgreSQL volumeClaimTemplates |
| statefulset.podManagementPolicy | string | `"Parallel"` | How PostgreSQL pods are created during the initial scaleup |
| statefulset.replicas | string | `""` | Desired number of PodTemplate replicas for PostgreSQL (overrides `nodeCount`) |
| statefulset.serviceName | string | `""` | Override for the PostgreSQL' StatefulSet serviceName field, it will be autogenerated if unset |
| statefulset.template | object | `{}` | Template to use for all pods created by the PostgreSQL StatefulSet (overrides `podTemplates.*`) |
| statefulset.updateStrategy | object | See `values.yaml` | Strategy that will be employed to update the pods in the PostgreSQL StatefulSet |
| tls.caCertFilename | string | `""` | CA certificate filename in the secret (will be ignored if empty) |
| tls.certFilename | string | `""` | Certificate filename in the secret (will be ignored if empty) |
| tls.crlFilename | string | `""` | Certificate revocation list filename in the secret (will be ignored if empty) |
| tls.enabled | bool | `false` | Enable SSL/TLS |
| tls.existingSecret | string | `""` | Name of the secret containing the PostgreSQL certificates |
| tls.keyFilename | string | `""` | Certificate key filename in the secret (will be ignored if empty) |
| tls.sslMode | string | `""` | Whether or with what priority a secure SSL TCP/IP connection will be negotiated with the server. Valid values: prefer (default), disable, allow, require, verify-ca, verify-full |

### Override Values

To override a parameter, add *--set* flags to the *helm install* command. For example:

```console
helm install my-release --set images.postgresql.tag=17.4 oci://dp.apps.rancher.io/charts/postgresql
```

Alternatively, you can override the parameter values using a custom YAML file with the *-f* flag. For example:

```console
helm install my-release -f custom-values.yaml oci://dp.apps.rancher.io/charts/postgresql
```

Read more about [Values files](https://helm.sh/docs/chart_template_guide/values_files/) in the [Helm documentation](https://helm.sh/docs/).

## Missing Features

The following features are acknowledged missing from this Helm chart, and are expected to be added in a future revision:

* Proxy to the current master node in PostgreSQL configurations with replication
* Synchronous replication mode
* High availability mode
