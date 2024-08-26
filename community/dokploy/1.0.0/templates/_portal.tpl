{{- define "dokploy.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: /
  port: {{ .Values.dokployNetwork.httpPort | quote }}
  protocol: {{ if .Values.dokployNetwork.certificateID }}https{{ else }}http{{ end }}
  host: $node_ip
{{- end -}}