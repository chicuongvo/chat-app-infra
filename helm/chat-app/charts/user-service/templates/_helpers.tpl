{{- define "user-service.fullname" -}}
{{- printf "%s-user-service" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
