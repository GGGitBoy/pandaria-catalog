{{- define "kubernetes-rbac-agent.app.name" -}}
{{ .Release.Name | trunc 52 | trimSuffix "-" }}-rbac-agent
{{- end -}}

{{- define "kubernetes-rbac-agent.global.name" -}}
{{ .Release.Namespace | trunc 52 | trimSuffix "-" }}-rbac-agent
{{- end -}}

{{- define "kubernetes-rbac-agent.serviceaccount.name" -}}
{{ include "kubernetes-rbac-agent.app.name" . }}
{{- end -}}

{{- define "kubernetes-rbac-agent.pull-secret.name" -}}
{{ include "kubernetes-rbac-agent.app.name" . }}-pull-secret
{{- end -}}

{{- define "kubernetes-rbac-agent.externalOrInternal" -}}
{{- if .external }}
{{- tpl .external . }}
{{- else }}
{{- template "kubernetes-rbac-agent.app.name" . }}-{{ .internalName }}
{{- end }}
{{- end }}

{{- define "kubernetes-rbac-agent.api-key.secret.internal.name" -}}
{{ include "kubernetes-rbac-agent.app.name" . }}-api-key
{{- end -}}

{{- define "kubernetes-rbac-agent.url.configmap.internal.name" -}}
{{ include "kubernetes-rbac-agent.app.name" . }}-url
{{- end -}}

{{- define "kubernetes-rbac-agent.clusterName.configmap.internal.name" -}}
{{ include "kubernetes-rbac-agent.app.name" . }}-cluster-name
{{- end -}}

{{- define "kubernetes-rbac-agent.api-key.secret.name" -}}
{{ include "kubernetes-rbac-agent.externalOrInternal" (merge (dict "external" .Values.global.apiKey.fromSecret "internalName" "api-key") .) | quote }}
{{- end }}

{{- define "kubernetes-rbac-agent.url.configmap.name" -}}
{{ include "kubernetes-rbac-agent.externalOrInternal" (merge (dict "external" .Values.url.fromConfigMap "internalName" "url") .) | quote }}
{{- end }}

{{- define "kubernetes-rbac-agent.clusterName.configmap.name" -}}
{{ include "kubernetes-rbac-agent.externalOrInternal" (merge (dict "external" .Values.clusterName.fromConfigMap "internalName" "cluster-name") .) | quote }}
{{- end }}

{{- define "kubernetes-rbac-agent.image.registry.global" -}}
  {{- if .Values.global }}
    {{- .Values.global.imageRegistry | default "quay.io" -}}
  {{- else -}}
    quay.io
  {{- end -}}
{{- end -}}

{{- define "kubernetes-rbac-agent.image.registry" -}}
  {{- if ((.ContainerConfig).image).registry -}}
    {{- tpl .ContainerConfig.image.registry . -}}
  {{- else -}}
    {{- include "kubernetes-rbac-agent.image.registry.global" . }}
  {{- end -}}
{{- end -}}

{{- define "kubernetes-rbac-agent.image.pullSecrets" -}}
  {{- $pullSecrets := list }}
  {{- $pullSecrets = append $pullSecrets (include "kubernetes-rbac-agent.pull-secret.name" .) }}
  {{- range .Values.global.imagePullSecrets -}}
    {{- $pullSecrets = append $pullSecrets .  -}}
  {{- end -}}
  {{- if (not (empty $pullSecrets)) -}}
imagePullSecrets:
    {{- range $pullSecrets | uniq }}
  - name: {{ . }}
    {{- end }}
  {{- end -}}
{{- end -}}


{{/*
Returns a YAML with extra annotations.
*/}}
{{- define "kubernetes-rbac-agent.global.extraAnnotations" -}}
{{- with .Values.global.extraAnnotations }}
{{- toYaml . }}
{{- end }}
{{- end -}}

{{/*
Returns a YAML with extra labels.
*/}}
{{- define "kubernetes-rbac-agent.global.extraLabels" -}}
{{- with .Values.global.extraLabels }}
{{- toYaml . }}
{{- end }}
{{- end -}}