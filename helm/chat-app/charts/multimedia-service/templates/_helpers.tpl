{{- define "multimedia-service.fullname" -}}
{{- printf "%s-multimedia-service" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
