{{/*
    Print true if authentication is enabled, false otherwise.
*/}}
{{- define "application-collection.postgresql.auth.enabled" }}
    {{- .Values.auth.enabled }}
{{- end }}
