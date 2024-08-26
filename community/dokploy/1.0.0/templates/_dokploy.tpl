{{- define "dokploy.workload" -}}
workload:
  dokploy:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.dokployNetwork.hostNetwork }}
      containers:
        dokploy:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.dokployRunAs.user }}
            runAsGroup: {{ .Values.dokployRunAs.group }}
            readOnlyRootFilesystem: false
          env:
            DOKPLOY_PASSWORD: {{ .Values.dokployConfig.password }}
            DOKPLOY_NODE_NAME: {{ .Values.dokployConfig.nodeName }}
            NPM_CONFIG_REGISTRY: {{ .Values.dokployConfig.npmRegistry }}
            PNPM_REGISTRY: {{ .Values.dokployConfig.pnpmRegistry }}
          {{ with .Values.dokployConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: http
              path: /healthz
              port: {{ .Values.dokployNetwork.targetPort }}
            readiness:
              enabled: true
              type: http
              path: /healthz
              port: {{ .Values.dokployNetwork.targetPort }}
            startup:
              enabled: true
              type: http
              path: /healthz
              port: {{ .Values.dokployNetwork.targetPort }}

service:
  dokploy:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: dokploy
    ports:
      http:
        enabled: true
        primary: true
        port: {{ .Values.dokployNetwork.httpPort }}
        nodePort: {{ .Values.dokployNetwork.httpPort }}
        targetPort: {{ .Values.dokployNetwork.targetPort }}

persistence:
  data:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.dokployStorage.data) | nindent 4 }}
    targetSelector:
      dokploy:
        dokploy:
          mountPath: /app/data
  {{- range $idx, $storage := .Values.dokployStorage.additionalStorages }}
  {{ printf "dokploy-%v:" (int $idx) }}:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      dokploy:
        dokploy:
          mountPath: {{ $storage.mountPath }}
  {{- end }}

  {{- if .Values.dokployNetwork.certificateID }}
  certs:
    enabled: true
    type: secret
    objectName: dokploy-cert
    defaultMode: "0600"
    items:
      - key: tls.key
        path: tls.key
      - key: tls.crt
        path: tls.crt
      - key: tls.crt
        path: ca.crt
    targetSelector:
      dokploy:
        dokploy:
          mountPath: /app/certs
          readOnly: true

scaleCertificate:
  dokploy-cert:
    enabled: true
    id: {{ .Values.dokployNetwork.certificateID }}
  {{- end }}
{{- end -}}