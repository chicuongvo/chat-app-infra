{{- define "notification-service.fullname" -}}
{{- printf "%s-notification-service" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
