{{- define "chat-service.fullname" -}}
{{- printf "%s-chat-service" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
