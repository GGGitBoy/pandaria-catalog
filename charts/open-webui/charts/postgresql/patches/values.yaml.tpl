global:
  # -- Global override for the storage class
  storageClassName: ""
  # -- Global override for container image registry
  imageRegistry: ""
  # -- Global override for container image registry pull secrets
  imagePullSecrets: []

# -- Annotations to add to all deployed objects
commonAnnotations: {}
# -- Labels to add to all deployed objects
commonLabels: {}
# -- Override the resource name
fullnameOverride: ""
# -- Override the resource name prefix (will keep the release name)
nameOverride: ""
# -- Additional Kubernetes manifests to include in the chart
extraManifests: []
# -- Kubernetes cluster domain name
clusterDomain: cluster.local

images:
  postgresql:
    # -- Image registry to use for the PostgreSQL container
    registry: ${CONTAINER_REGISTRY}
    # -- Image repository to use for the PostgreSQL container
    repository: containers/postgresql
    # -- Image tag to use for the PostgreSQL container
    tag: "${APP_VERSION}"
    # -- Image digest to use for the PostgreSQL container (if set, `images.postgresql.tag` will be ignored)
    digest: ""
    # -- Image pull policy to use for the PostgreSQL container
    pullPolicy: IfNotPresent
  metrics:
    # -- Image registry to use for the PostgreSQL Server Exporter container
    registry: ${CONTAINER_REGISTRY}
    # -- Image repository to use for the PostgreSQL Server Exporter container
    repository: containers/postgres-exporter
    # -- Image tag to use for the PostgreSQL container
    tag: "0"
    # -- Image digest to use for the PostgreSQL container (if set, `images.metrics.tag` will be ignored)
    digest: ""
    # -- Image pull policy to use for the PostgreSQL container
    pullPolicy: IfNotPresent
  volume-permissions:
    # -- Image registry to use for the volume permissions init container
    registry: ${CONTAINER_REGISTRY}
    # -- Image pository to use for the volume permissions init container
    repository: containers/bci-busybox
    # -- Image tag to use for the volume permissions init container
    tag: "15.6"
    # -- Image digest to use for the volume permissions init container (if set, `images.volume-permissions.tag` will be ignored)
    digest: ""
    # -- Image pull policy to use for the volume-permissions container
    pullPolicy: IfNotPresent

containerPorts:
  # -- (int32) PostgreSQL port number for client connections
  postgresql: 5432
  # -- (int32) Port number where metrics will be exposed to
  metrics: 9187
  # -- (int32) Custom port number to expose in the PostgreSQL containers
  "*":
  # Note: This field is only added for documentation purposes

auth:
  # -- PostgreSQL database to create. If empty, the database will not be created
  database: ""
  # -- PostgreSQL username for the user to create. If empty, the user will not be created
  username: ""
  # -- PostgreSQL password for the user to create
  password: ""
  # -- PostgreSQL username for the superuser
  postgresUsername: postgres
  # -- PostgreSQL password for the superuser
  postgresPassword: ""
  # -- Replication username
  replicationUsername: replication
  # -- Replication password
  replicationPassword: ""
  # -- Name of a secret containing the secret for the PostgreSQL passwords (if set, `auth.password`, `auth.postgresPassword` and `auth.replicationPassword` will be ignored)
  existingSecret: ""
  # -- Password key in the secret
  # @default `password`
  passwordKey: password
  # -- PostgreSQL `postgres` user password key in the secret
  # @default `postgresPassword`
  postgresPasswordKey: postgresPassword
  # -- Replication user password key in the secret
  # @default `replicationPassword`
  replicationPasswordKey: replicationPassword
tls:
  # -- Enable SSL/TLS
  enabled: false
  # -- Name of the secret containing the PostgreSQL certificates
  existingSecret: ""
  # -- Whether or with what priority a secure SSL TCP/IP connection will be negotiated with the server. Valid values: prefer (default), disable, allow, require, verify-ca, verify-full
  sslMode: ""
  # -- Certificate filename in the secret (will be ignored if empty)
  certFilename: ""
  # -- Certificate key filename in the secret (will be ignored if empty)
  keyFilename: ""
  # -- CA certificate filename in the secret (will be ignored if empty)
  caCertFilename: ""
  # -- Certificate revocation list filename in the secret (will be ignored if empty)
  crlFilename: ""
# -- Configuration file name in the config map
configurationFile: postgresql.conf
# -- Configuration file name for host-based authentication (HBA) in the config map
hbaConfigurationFile: pg_hba.conf
# -- Configuration file name for user name mapping (ident) in the config map
identConfigurationFile: pg_ident.conf
# -- Extra configurations to add to the PostgreSQL configuration file. Can be defined as a string, a key-value map, or an array of entries.
# See: https://www.postgresql.org/docs/current/runtime-config.html
configuration: ""
# -- Extra configurations to add to the PostgreSQL host-based authentication (HBA) file. Can be defined as a string, a key-value map, or an array of entries.
# See: https://www.postgresql.org/docs/current/auth-pg-hba-conf.html
hbaConfiguration: ""
# -- Extra configurations to add to the user name mapping (ident) file. Can be defined as a string, a key-value map, or an array of entries.
# See: https://www.postgresql.org/docs/current/auth-username-maps.html
identConfiguration: ""
# -- Name of an existing config map for extra configurations to add to the PostgreSQL configuration file
existingConfigMap: ""
# -- ConfigMaps to deploy
# @default -- See `values.yaml`
configMap:
  # -- Create a config map for PostgreSQL configuration
  enabled: '{{ and (not .Values.existingConfigMap) (or .Values.configuration .Values.hbaConfiguration .Values.identConfiguration) }}'
  # See: https://www.postgresql.org/docs/current/runtime-config.html
  '{{ .Values.configurationFile }}': '{{ .Values.configuration }}'
  # See: https://www.postgresql.org/docs/current/auth-pg-hba-conf.html
  '{{ .Values.hbaConfigurationFile }}': '{{ .Values.hbaConfiguration }}'
  # See: https://www.postgresql.org/docs/current/auth-username-maps.html
  '{{ .Values.identConfigurationFile }}': '{{ .Values.identConfiguration }}'
  # -- (string) Custom configuration file to include, templates are allowed both in the config map name and contents
  "*":
  # Note: This field is only added for documentation purposes
# -- Secrets to deploy
# @default -- See `values.yaml`
secret:
  # -- Create a secret for PostgreSQL credentials
  # @default -- `true` if authentication is enabled without existing secret, `false` otherwise
  enabled: '{{ not .Values.auth.existingSecret }}'
  '{{ .Values.auth.passwordKey }}':
      enabled: '{{ not (empty .Values.auth.username) }}'
      value: '{{ default (randAlphaNum 16) .Values.auth.password }}'
  '{{ .Values.auth.postgresPasswordKey }}': '{{ default (randAlphaNum 16) .Values.auth.postgresPassword }}'
  '{{ .Values.auth.replicationPasswordKey }}': '{{ default (randAlphaNum 16) .Values.auth.replicationPassword }}'
  # -- (string) Custom secret to include, templates are allowed both in the secret name and contents
  "*":
  # Note: This field is only added for documentation purposes
# -- Desired number of PostgreSQL nodes to deploy (counting the PostgreSQL primary node)
nodeCount: 1

statefulset:
  # -- Enable the StatefulSet template for PostgreSQL standalone mode
  enabled: true
  # -- Override for the PostgreSQL' StatefulSet serviceName field, it will be autogenerated if unset
  serviceName: ""
  # -- Template to use for all pods created by the PostgreSQL StatefulSet (overrides `podTemplates.*`)
  template: {}
  # -- Desired number of PodTemplate replicas for PostgreSQL (overrides `nodeCount`)
  replicas: ""
  # -- Strategy that will be employed to update the pods in the PostgreSQL StatefulSet
  # @default -- See `values.yaml`
  updateStrategy:
    type: RollingUpdate
  # -- How PostgreSQL pods are created during the initial scaleup
  podManagementPolicy: Parallel
  # -- Lifecycle of the persistent volume claims created from PostgreSQL volumeClaimTemplates
  persistentVolumeClaimRetentionPolicy: {}
  #  whenScaled: Retain
  #  whenDeleted: Retain
  # -- Custom attributes for the PostgreSQL StatefulSet (see [`StatefulSetSpec` API reference](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/stateful-set-v1/#StatefulSetSpec))
  "*":
  # Note: This field is only added for documentation purposes

podTemplates:
  # -- Annotations to add to all pods in the PostgreSQL StatefulSet's PodTemplate
  # @default -- See `values.yaml`
  annotations:
    kubectl.kubernetes.io/default-container: postgresql
  # -- Labels to add to all pods in the PostgreSQL StatefulSet's PodTemplate
  labels: {}
  # -- Init containers to deploy in the PostgreSQL PodTemplate
  # @default -- See `values.yaml`
  # Each field has the init container name as key, and a YAML object template with the values; you must set `enabled: true` to enable it
  initContainers:
    volume-permissions:
      # -- Enable the volume-permissions init container in the PostgreSQL PodTemplate
      enabled: false
      # -- Image override for the PostgreSQL volume-permissions init container (if set, `images.volume-permissions.{name,tag,digest}` values will be ignored for this container)
      image: ""
      # -- Image pull policy override for the PostgreSQL volume-permissions init container (if set `images.volume-permissions.pullPolicy` values will be ignored for this container)
      imagePullPolicy: ""
      # -- Entrypoint override for the PostgreSQL volume-permissions container
      # @default -- See `values.yaml`
      command:
        - /bin/sh
        - -ec
        - |
          chown -R {{ .Values.containerSecurityContext.runAsUser }} /mnt/postgresql/data
      # -- Arguments override for the PostgreSQL volume-permissions init container entrypoint
      args: []
      # -- Object with the environment variables templates to use in the PostgreSQL volume-permissions init container, the values can be specified as an object or a string; when using objects you must also set `enabled: true` to enable it
      # @default -- No environment variables are set
      env: {}
      # -- List of sources from which to populate environment variables to the PostgreSQL volume-permissions init container (e.g. a ConfigMaps or a Secret)
      envFrom: []
      # -- Custom volume mounts for the PostgreSQL volume-permissions init container, templates are allowed in all fields
      # @default -- See `values.yaml`
      # Each field has the volume mount name as key, and a YAML string template with the values; you must set `enabled: true` to enable it
      volumeMounts:
        data:
          enabled: true
          mountPath: /mnt/postgresql/data
      # -- PostgreSQL init-containers resource requirements
      resources: {}
      # We usually recommend not to specify default resources and to leave this as a conscious
      # choice for the user. This also increases chances charts run on environments with little
      # resources, such as Minikube. If you do want to specify resources, uncomment the following
      # lines, adjust them as necessary, and remove the curly braces after 'resources:'
      #   limits:
      #    cpu: 100m
      #    memory: 128Mi
      #   requests:
      #    cpu: 100m
      #    memory: 128Mi
      # -- Security context override for the PostgreSQL volume-permissions init container (if set, `containerSecurityContext.*` values will be ignored for this container)
      # @default -- See `values.yaml`
      securityContext:
        runAsUser: 0
      # -- Custom attributes for the PostgreSQL volume-permissions init container (see [`Container` API spec](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#Container))
      "*":
      # Note: This field is only added for documentation purposes
  # -- Containers to deploy in the PostgreSQL PodTemplate
  # @default -- See `values.yaml`
  # Each field has the container name as key, and a YAML object template with the values; you must set `enabled: true` to enable it
  containers:
    postgresql:
      # -- Enable the PostgreSQL container in the PodTemplate
      enabled: true
      # -- Image override for the PostgreSQL container (if set, `images.postgresql.{name,tag,digest}` values will be ignored for this container)
      image: ""
      # -- Image pull policy override for the PostgreSQL container (if set `images.postgresql.pullPolicy` values will be ignored for this container)
      imagePullPolicy: ""
      # -- Entrypoint override for the PostgreSQL container
      # @default -- See `values.yaml`
      command:
        - /bin/bash
        - -ec
        - |
          exec /mnt/postgresql/scripts/postgresql-entrypoint.sh
      # -- Arguments override for the PostgreSQL container entrypoint
      args: []
      # -- Ports override for the PostgreSQL container (if set, `containerPorts.*` values will be ignored for this container)
      ports: {}
      # -- Object with the environment variables templates to use in the PostgreSQL container, the values can be specified as an object or a string; when using objects you must also set `enabled: true` to enable it
      # @default -- See `values.yaml`
      env:
        # Using a subdir so that initdb can chmod/chown the directory
        PGDATA: '{{ .Values.podTemplates.containers.postgresql.volumeMounts.data.mountPath }}/pgdata'
        PGPORT: '{{ .Values.containerPorts.postgresql }}'
        PGUSER: '{{ .Values.auth.postgresUsername }}'
        PGPASSWORD: '$(_POSTGRES_PASSWORD)'
        PGSSLMODE:
          enabled: '{{ and .Values.tls.enabled (not (empty .Values.tls.sslMode)) }}'
          value: '{{ .Values.tls.sslMode }}'
        PGSSLCERT:
          enabled: '{{ and .Values.tls.enabled (not (empty .Values.tls.certFilename)) }}'
          value: '{{ .Values.podTemplates.containers.postgresql.volumeMounts.certs.mountPath }}/{{ .Values.tls.certFilename }}'
        PGSSLKEY:
          enabled: '{{ and .Values.tls.enabled (not (empty .Values.tls.keyFilename)) }}'
          value: '{{ .Values.podTemplates.containers.postgresql.volumeMounts.certs.mountPath }}/{{ .Values.tls.keyFilename }}'
        PGSSLROOTCERT:
          enabled: '{{ and .Values.tls.enabled (not (empty .Values.tls.caCertFilename)) }}'
          value: '{{ .Values.podTemplates.containers.postgresql.volumeMounts.certs.mountPath }}/{{ .Values.tls.caCertFilename }}'
        PGSSLCRL:
          enabled: '{{ and .Values.tls.enabled (not (empty .Values.tls.crlFilename)) }}'
          value: '{{ .Values.podTemplates.containers.postgresql.volumeMounts.certs.mountPath }}/{{ .Values.tls.crlFilename }}'
        # Environment variables used as placeholders or by initialization scripts
        _FQDN_CLUSTER_PREFIX: '{{ printf "%s.%s.svc.%s" (include "application-collection.fullName" (dict "suffix" "headless" "context" $)) .Release.Namespace .Values.clusterDomain }}'
        _POSTGRES_PRIMARY_HOST: '{{ printf "%s.%s.%s.svc.%s" (include "application-collection.fullName" (dict "suffix" "0" "context" $)) (include "application-collection.fullName" (dict "suffix" "headless" "context" $)) .Release.Namespace .Values.clusterDomain }}'
        _POSTGRES_CLUSTER_APPLICATION_NAME: 'walreceiver'
        _POSTGRES_INITIAL_DATABASE:
          enabled: '{{ not (empty .Values.auth.database) }}'
          value: '{{ .Values.auth.database }}'
        _POSTGRES_INITIAL_USERNAME:
          enabled: '{{ not (empty .Values.auth.username) }}'
          value: '{{ .Values.auth.username }}'
        _POSTGRES_INITIAL_PASSWORD:
          enabled: '{{ not (empty .Values.auth.username) }}'
          valueFrom:
            secretKeyRef:
              name: '{{ coalesce .Values.auth.existingSecret (include "application-collection.fullName" .) }}'
              key: '{{ .Values.auth.passwordKey }}'
        _POSTGRES_PASSWORD:
          enabled: true
          valueFrom:
            secretKeyRef:
              name: '{{ coalesce .Values.auth.existingSecret (include "application-collection.fullName" .) }}'
              key: '{{ .Values.auth.postgresPasswordKey }}'
        _POSTGRES_CONF_FILE:
          enabled: '{{ and .Values.configMap.enabled .Values.configuration }}'
          value: '{{ .Values.podTemplates.containers.postgresql.volumeMounts.conf.mountPath }}/{{ .Values.configurationFile }}'
        _POSTGRES_HBA_CONF_FILE:
          enabled: '{{ and .Values.configMap.enabled .Values.hbaConfiguration }}'
          value: '{{ .Values.podTemplates.containers.postgresql.volumeMounts.conf.mountPath }}/{{ .Values.hbaConfigurationFile }}'
        _POSTGRES_IDENT_CONF_FILE:
          enabled: '{{ and .Values.configMap.enabled .Values.identConfiguration }}'
          value: '{{ .Values.podTemplates.containers.postgresql.volumeMounts.conf.mountPath }}/{{ .Values.identConfigurationFile }}'
        _POSTGRES_REPLICATION_USERNAME: '{{ .Values.auth.replicationUsername }}'
        _POSTGRES_REPLICATION_PASSWORD:
          enabled: true
          valueFrom:
            secretKeyRef:
              name: '{{ coalesce .Values.auth.existingSecret (include "application-collection.fullName" .) }}'
              key: '{{ .Values.auth.replicationPasswordKey }}'
        _POSTGRES_REPLICA_TO_PRIMARY_CONNECTION_ATTEMPTS: '30'
        _POSTGRES_REPLICA_TO_PRIMARY_CLONE_ATTEMPTS: '60'
        _POSTGRES_SSL:
          enabled: '{{ and .Values.tls.enabled }}'
          value: 'on'
        _POSTGRES_SSL_CA_FILE:
          enabled: '{{ and .Values.tls.enabled (not (empty .Values.tls.caCertFilename)) }}'
          value: '{{ .Values.podTemplates.containers.postgresql.volumeMounts.certs.mountPath }}/{{ .Values.tls.caCertFilename }}'
        _POSTGRES_SSL_CERT_FILE:
          enabled: '{{ and .Values.tls.enabled (not (empty .Values.tls.certFilename)) }}'
          value: '{{ .Values.podTemplates.containers.postgresql.volumeMounts.certs.mountPath }}/{{ .Values.tls.certFilename }}'
        _POSTGRES_SSL_CRL_FILE:
          enabled: '{{ and .Values.tls.enabled (not (empty .Values.tls.crlFilename)) }}'
          value: '{{ .Values.podTemplates.containers.postgresql.volumeMounts.certs.mountPath }}/{{ .Values.tls.crlFilename }}'
        _POSTGRES_SSL_KEY_FILE:
          enabled: '{{ and .Values.tls.enabled (not (empty .Values.tls.keyFilename)) }}'
          value: '{{ .Values.podTemplates.containers.postgresql.volumeMounts.certs.mountPath }}/{{ .Values.tls.keyFilename }}'
        _POSTGRES_SSL_MODE:
          enabled: '{{ and .Values.tls.enabled (not (empty .Values.tls.sslMode)) }}'
          value: '{{ .Values.tls.sslMode }}'
      # -- List of sources from which to populate environment variables to the PostgreSQL container (e.g. a ConfigMaps or a Secret)
      envFrom: []
      # -- Volume mount templates for the PostgreSQL container, templates are allowed in all fields
      # @default -- See `values.yaml`
      # Each field has the volume mount name as key, and a YAML string template with the values; you must set `enabled: true` to enable it
      volumeMounts:
        conf:
          enabled: '{{ .Values.configMap.enabled }}'
          mountPath: /mnt/postgresql/conf
          readOnly: true
        data:
          enabled: true
          mountPath: /mnt/postgresql/data
        scripts:
          enabled: true
          mountPath: /mnt/postgresql/scripts
          readOnly: true
        certs:
          enabled: '{{ .Values.tls.enabled }}'
          mountPath: /mnt/postgresql/certs
          readOnly: true
      # -- Custom resource requirements for the PostgreSQL container
      resources: {}
      # We usually recommend not to specify default resources and to leave this as a conscious
      # choice for the user. This also increases chances charts run on environments with little
      # resources, such as Minikube. If you do want to specify resources, uncomment the following
      # lines, adjust them as necessary, and remove the curly braces after 'resources:'
      #   limits:
      #    cpu: 100m
      #    memory: 128Mi
      #   requests:
      #    cpu: 100m
      #    memory: 128Mi
      # -- Security context override for the PostgreSQL container (if set, `containerSecurityContext.*` values will be ignored for this container)
      securityContext: {}
      livenessProbe:
        # -- Enable liveness probe for PostgreSQL
        enabled: true
        # -- Command to execute for the PostgreSQL startup probe
        # @default -- See `values.yaml`
        exec:
          command:
            - /mnt/postgresql/scripts/postgresql-liveness-check.sh
        # -- Number of seconds after the PostgreSQL container has started before liveness probes are initiated
        initialDelaySeconds: 10
        # -- How often (in seconds) to perform the PostgreSQL liveness probe
        periodSeconds: 10
        # -- Number of seconds after which the PostgreSQL liveness probe times out
        timeoutSeconds: 5
        # -- Minimum consecutive failures for the PostgreSQL liveness probe to be considered failed after having succeeded
        failureThreshold: 5
        # -- Minimum consecutive successes for the PostgreSQL liveness probe to be considered successful after having failed
        successThreshold: 1
      readinessProbe:
        # -- Enable readiness probe for PostgreSQL
        enabled: true
        # -- Command to execute for the PostgreSQL startup probe
        # @default -- See `values.yaml`
        exec:
          command:
            - /mnt/postgresql/scripts/postgresql-readiness-check.sh
        # -- Number of seconds after the PostgreSQL container has started before readiness probes are initiated
        initialDelaySeconds: 10
        # -- How often (in seconds) to perform the PostgreSQL readiness probe
        periodSeconds: 10
        # -- Number of seconds after which the PostgreSQL readiness probe times out
        timeoutSeconds: 5
        # -- Minimum consecutive failures for the PostgreSQL readiness probe to be considered failed after having succeeded
        failureThreshold: 5
        # -- Minimum consecutive successes for the PostgreSQL readiness probe to be considered successful after having failed
        successThreshold: 1
      startupProbe:
        # -- Enable startup probe for PostgreSQL
        enabled: false
        # -- Port number used to check if the PostgreSQL service is alive
        # @default -- See `values.yaml`
        tcpSocket:
          port: postgresql
        # -- Number of seconds after the PostgreSQL container has started before startup probes are initiated
        initialDelaySeconds: 0
        # -- How often (in seconds) to perform the PostgreSQL startup probe
        periodSeconds: 10
        # -- Number of seconds after which the PostgreSQL startup probe times out
        timeoutSeconds: 5
        # -- Minimum consecutive failures for the PostgreSQL startup probe to be considered failed after having succeeded
        failureThreshold: 10
        # -- Minimum consecutive successes for the PostgreSQL startup probe to be considered successful after having failed
        successThreshold: 1
      # -- Custom attributes for the PostgreSQL container (see [`Container` API spec](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#Container))
      "*":
      # Note: This field is only added for documentation purposes
    metrics:
      # -- Enable the postgres-exporter container in the PostgreSQL PodTemplate
      # @default -- Same value as `metrics.enabled`
      enabled: '{{ .Values.metrics.enabled }}'
      # -- Image override for the postgres-exporter container (if set, `images.metrics.{name,tag,digest}` values will be ignored for this container)
      image: ""
      # -- Image pull policy override for the postgres-exporter container (if set `images.metrics.pullPolicy` values will be ignored for this container)
      imagePullPolicy: ""
      # -- Entrypoint override for the postgres-exporter container
      command: ""
      # -- Arguments override for the postgres-exporter container entrypoint
      args: []
      # -- Ports override for the postgres-exporter container (if set, `containerPorts.*` values will be ignored for this container)
      ports: {}
      # -- Object with the environment variables templates to use in the postgres-exporter container, the values can be specified as an object or a string; when using objects you must also set `enabled: true` to enable it
      # @default -- See `values.yaml`
      env:
        DATA_SOURCE_URI: '{{ printf "127.0.0.1:%d/?sslmode=disable" (int .Values.containerPorts.postgresql) }}'
        DATA_SOURCE_USER: '{{ .Values.auth.postgresUsername }}'
        DATA_SOURCE_PASS:
          enabled: true
          valueFrom:
            secretKeyRef:
              name: '{{ coalesce .Values.auth.existingSecret (include "application-collection.fullName" .) }}'
              key: '{{ .Values.auth.postgresPasswordKey }}'
      # -- List of sources from which to populate environment variables to the postgres-exporter container (e.g. a ConfigMaps or a Secret)
      envFrom: []
      # -- Volume mount templates for the postgres-exporter container, templates are allowed in all fields
      # @default -- See `values.yaml`
      # Each field has the volume mount name as key, and a YAML string template with the values; you must set `enabled: true` to enable it
      volumeMounts:
        certs:
          enabled: '{{ and .Values.tls.enabled }}'
          mountPath: /mnt/postgresql/certs
          readOnly: true
      # -- Custom resource requirements for the postgres-exporter container
      resources: {}
      # We usually recommend not to specify default resources and to leave this as a conscious
      # choice for the user. This also increases chances charts run on environments with little
      # resources, such as Minikube. If you do want to specify resources, uncomment the following
      # lines, adjust them as necessary, and remove the curly braces after 'resources:'
      #   limits:
      #    cpu: 100m
      #    memory: 128Mi
      #   requests:
      #    cpu: 100m
      #    memory: 128Mi
      # -- Security context override for the postgres-exporter container (if set, `containerSecurityContext.*` values will be ignored for this container)
      securityContext: {}
      livenessProbe:
        # -- Enable liveness probe for postgres-exporter
        enabled: true
        # -- Port number used to check if the postgres-exporter service is alive
        # @default -- See `values.yaml`
        tcpSocket:
          port: metrics
        # -- Number of seconds after the postgres-exporter container has started before liveness probes are initiated
        initialDelaySeconds: 10
        # -- How often (in seconds) to perform the postgres-exporter liveness probe
        periodSeconds: 10
        # -- Number of seconds after which the postgres-exporter liveness probe times out
        timeoutSeconds: 5
        # -- Minimum consecutive failures for the postgres-exporter liveness probe to be considered failed after having succeeded
        failureThreshold: 5
        # -- Minimum consecutive successes for the postgres-exporter liveness probe to be considered successful after having failed
        successThreshold: 1
      readinessProbe:
        # -- Enable readiness probe for postgres-exporter
        enabled: true
        # -- HTTP endpoint used to check if the postgres-exporter service is ready
        # @default -- See `values.yaml`
        httpGet:
          port: metrics
          path: /
        # -- Number of seconds after the postgres-exporter container has started before readiness probes are initiated
        initialDelaySeconds: 10
        # -- How often (in seconds) to perform the postgres-exporter readiness probe
        periodSeconds: 10
        # -- Number of seconds after which the postgres-exporter readiness probe times out
        timeoutSeconds: 5
        # -- Minimum consecutive failures for the postgres-exporter readiness probe to be considered failed after having succeeded
        failureThreshold: 5
        # -- Minimum consecutive successes for the postgres-exporter readiness probe to be considered successful after having failed
        successThreshold: 1
      startupProbe:
        # -- Enable startup probe for postgres-exporter
        enabled: false
        # -- Port number used to check if the postgres-exporter service has been started
        # @default -- See `values.yaml`
        tcpSocket:
          port: metrics
        # -- Number of seconds after the postgres-exporter container has started before startup probes are initiated
        initialDelaySeconds: 0
        # -- How often (in seconds) to perform the postgres-exporter startup probe
        periodSeconds: 10
        # -- Number of seconds after which the postgres-exporter startup probe times out
        timeoutSeconds: 5
        # -- Minimum consecutive failures for the postgres-exporter startup probe to be considered failed after having succeeded
        failureThreshold: 10
        # -- Minimum consecutive successes for the postgres-exporter startup probe to be considered successful after having failed
        successThreshold: 1
      # -- Custom attributes for the postgres-exporter container (see [`Container` API spec](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#Container))
      "*":
      # Note: This field is only added for documentation purposes
  # -- Custom pull secrets for the PostgreSQL container in the PodTemplate
  imagePullSecrets: []
  # -- Volume templates for the PostgreSQL PodTemplate, templates are allowed in all fields
  # @default -- See `values.yaml`
  # Each field has the volume name as key, and a YAML string template with the values; you must set `enabled: true` to enable it
  volumes:
    conf:
      enabled: true
      configMap:
        name: '{{ include "application-collection.fullName" $ }}'
        defaultMode: 0o400
    data:
      enabled: '{{ and (not .Values.statefulset.volumeClaimTemplates) (not .Values.persistence.enabled) }}'
      emptyDir:
        medium: ""
    scripts:
      enabled: true
      configMap:
        name: '{{ include "application-collection.fullName" (dict "suffix" "scripts" "context" $) }}'
        defaultMode: 0o550
    certs:
      enabled: '{{ .Values.tls.enabled }}'
      secret:
        secretName: '{{ tpl .Values.tls.existingSecret . }}'
        defaultMode: 0o400
  # -- Service account name override for the pods in the PostgreSQL PodTemplate (if set, `serviceAccount.name` will be ignored)
  serviceAccountName: ""
  # -- Security context override for the pods in the PostgreSQL PodTemplate (if set, `podSecurityContext.*` values will be ignored)
  securityContext: {}
  # -- Custom attributes for the pods in the PostgreSQL PodTemplate (see [`PodSpec` API reference](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#PodSpec))
  "*":
  # Note: This field is only added for documentation purposes

service:
  # -- Create a service for PostgreSQL (apart from the headless service)
  enabled: true
  # -- Custom annotations to add to the service for PostgreSQL
  annotations: {}
  # -- PostgreSQL service type
  type: ClusterIP
  # PostgreSQL service nodePort values
  nodePorts:
    # -- (int32) Service nodePort override for PostgreSQL client connections
    postgresql: ""
    # -- (int32) Service nodePort override for custom PostgreSQL ports specified in `containerPorts.*`
    "*":
    # Note: This field is only added for documentation purposes
  # Service port values
  ports:
    # -- (int32) Service port override for PostgreSQL client connections
    postgresql: ""
    # -- (int32) Service port override for custom PostgreSQL ports specified in `containerPorts.*`
    "*":
    # Note: This field is only added for documentation purposes
  # -- Custom attributes for the PostgreSQL service (see [`ServiceSpec` API reference](https://kubernetes.io/docs/reference/kubernetes-api/service-resources/service-v1/#ServiceSpec))
  "*":
  # Note: This field is only added for documentation purposes

headlessService:
  # -- Custom annotations to add to the headless service for PostgreSQL
  annotations: {}
  # -- PostgreSQL headless service type
  type: ClusterIP
  # IP address of the service
  # When clusterIP is "None", no virtual IP is allocated and the endpoints are published as a set of endpoints rather than a virtual IP
  clusterIP: None
  # -- Disregard indications of ready/not-ready
  # The primary use case for setting this field is for a StatefulSet's Headless Service to propagate SRV DNS records for its Pods for the purpose of peer discovery
  publishNotReadyAddresses: true
  # Headless service port values
  ports:
    # -- (int32) Headless service port override for PostgreSQL client connections
    postgresql: ""
    # -- (int32) Headless service port override for custom PostgreSQL ports specified in `containerPorts.*`
    "*":
    # Note: This field is only added for documentation purposes
  # -- Custom attributes for the PostgreSQL headless service (see [`ServiceSpec` API reference](https://kubernetes.io/docs/reference/kubernetes-api/service-resources/service-v1/#ServiceSpec))
  "*":
  # Note: This field is only added for documentation purposes

metrics:
  # -- Expose PostgreSQL metrics
  enabled: false
  # -- Annotations to add to all pods that expose metrics
  # @default -- See `values.yaml`
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: '{{ coalesce .Values.containerPorts.metrics .Values.containerPorts.client }}'
  prometheusRule:
    # -- Content of the Prometheus rule file
    # See https://prometheus.io/docs/prometheus/latest/configuration/recording_rules/
    configuration: {}
    # Example Prometheus rule file copied from https://samber.github.io/awesome-prometheus-alerts/rules.html#postgresql
    # - alert: PostgresqlDown
    #   expr: pg_up == 0
    #   for: 0m
    #   labels:
    #     severity: critical
    #   annotations:
    #     summary: Postgresql down (instance {{ $labels.instance }})
    #     description: "Postgresql instance is down\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
    # -- Create a PrometheusRule resource (also requires `metrics.enabled` to be enabled)
    enabled: false
    # -- Additional labels that will be added to the PrometheusRule resource
    labels: {}
    # -- Namespace for the PrometheusRule resource (defaults to the release namespace)
    namespace: ""
  service:
    # -- Create a service for postgres-exporter (apart from the headless service)
    enabled: true
    # -- Custom annotations to add to the service for postgres-exporter
    annotations: {}
    # -- Service type
    type: ClusterIP
    # Service nodePort values
    nodePorts:
      # -- (int32) Service nodePort override for postgres-exporter metrics connections
      metrics: ""
      # -- (int32) Service nodePort override for custom ports specified in `containerPorts.*`
      "*":
      # Note: This field is only added for documentation purposes
    # Service port values
    ports:
      # -- (int32) Service port override for postgres-exporter metrics connections
      metrics: ""
      # -- (int32) Service port override for custom ports specified in `containerPorts.*`
      "*":
      # Note: This field is only added for documentation purposes
    # -- Custom attributes for the service (see [`ServiceSpec` API reference](https://kubernetes.io/docs/reference/kubernetes-api/service-resources/service-v1/#ServiceSpec))
    "*":
    # Note: This field is only added for documentation purposes

persistence:
  # -- Enable persistent volume claims for PostgreSQL pods
  enabled: true
  # -- Custom annotations to add to the persistent volume claims used by PostgreSQL pods
  annotations: {}
  # -- Custom labels to add to the persistent volume claims used by PostgreSQL pods
  labels: {}
  # -- Name of an existing PersistentVolumeClaim to use by PostgreSQL pods
  existingClaim: ""
  # -- Persistent volume access modes
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      # -- Size of the persistent volume claim to create for PostgreSQL pods
      storage: 8Gi
  # -- Storage class name to use for the PostgreSQL persistent volume claim
  storageClassName: ""

podSecurityContext:
  # -- Enable pod security context
  enabled: true

containerSecurityContext:
  # -- Enable container security context
  enabled: true
  # -- Allow privilege escalation within containers
  allowPrivilegeEscalation: false
  # -- Run containers as a non-root user
  runAsNonRoot: true
  # -- Which user ID to run the container as
  runAsUser: 1000

networkPolicy:
  # -- Create a NetworkPolicy resource
  enabled: false
  # -- Allow all external connections from and to the pods
  allowExternalConnections: true
  egress:
    # -- Create an egress network policy (requires also `networkPolicy.enabled`)
    enabled: true
    # -- Allow all external egress connections from the pods (requires also `networkPolicy.allowExternalConnections`)
    allowExternalConnections: true
    # -- Custom additional egress rules to enable in the NetworkPolicy resource
    extraRules: []
    # -- List of namespace labels for which to allow egress connections, when external connections are disallowed
    namespaceLabels: {}
    # -- List of pod labels for which to allow egress connections, when external connections are disallowed
    podLabels: {}
    # Network policy port overrides for egress connections
    ports:
      # -- (int32) Network policy port override for PostgreSQL client connections for egress connections
      client: ""
      # -- (int32) Network policy port override for PostgreSQL peer connections for egress connections
      peer: ""
      # -- (int32) Network policy port override for custom ports specified in `containerPorts.*` for egress connections
      "*":
      # Note: This field is only added for documentation purposes
  ingress:
    # -- Create an ingress network policy (requires also `networkPolicy.enabled`)
    enabled: true
    # -- Allow all external ingress connections to the pods (requires also `networkPolicy.allowExternalConnections`)
    allowExternalConnections: true
    # -- List of namespace labels for which to allow ingress connections, when external connections are disallowed
    namespaceLabels: {}
    # -- List of pod labels for which to allow ingress connections, when external connections are disallowed
    podLabels: {}
    # -- Custom additional ingress rules to enable in the NetworkPolicy resource
    extraRules: []
    # Network policy port overrides for ingress connections
    ports:
      # -- (int32) Network policy port override for PostgreSQL client connections for ingress connections
      client: ""
      # -- (int32) Network policy port override for PostgreSQL peer connections for ingress connections
      peer: ""
      # -- (int32) Network policy port override for custom ports specified in `containerPorts.*` for ingress connections
      "*":
      # Note: This field is only added for documentation purposes

podDisruptionBudget:
  # -- Create a pod disruption budget
  enabled: false
  # -- Number of pods from that set that must still be available after the eviction, this option is mutually exclusive with maxUnavailable
  minAvailable: ""
  # -- Number of pods from that can be unavailable after the eviction, this option is mutually exclusive with minAvailable
  maxUnavailable: ""

serviceAccount:
  # -- Create or use an existing service account
  enabled: false
  # -- Add custom annotations to the ServiceAccount
  annotations: {}
  # -- Add custom labels to the ServiceAccount
  labels: {}
  # -- Name of the ServiceAccount to use
  name: ""
  # -- Whether pods running as this service account should have an API token automatically mounted
  automountServiceAccountToken: true
  # -- List of references to secrets in the same namespace to use for pulling any images in pods that reference this ServiceAccount
  imagePullSecrets: []
  # -- List of secrets in the same namespace that pods running using this ServiceAccount are allowed to use
  secrets: []
