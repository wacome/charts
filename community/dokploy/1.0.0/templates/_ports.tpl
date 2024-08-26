{{- define "dokploy.container.ports" -}}
{{- $rootCtx := .rootCtx -}}
{{- $objectData := .objectData -}}

{{- $ports := list -}}
{{- range $name, $service := $rootCtx.Values.service -}}
  {{- if kindIs "map" $service -}}
    {{- if hasKey $service "enabled" -}}
      {{- if $service.enabled -}}
        {{- $serviceValues := $service -}}
        {{- if hasKey $serviceValues "ports" -}}
          {{- range $name, $port := $serviceValues.ports -}}
            {{- if kindIs "map" $port -}}
              {{- if hasKey $port "enabled" -}}
                {{- if $port.enabled -}}
                  {{- $portProtocol := $port.protocol | default "TCP" -}}
                  {{- $portName := $name -}}
                  {{- if $port.name -}}
                    {{- $portName = $port.name -}}
                  {{- end -}}
                  {{- $portNumber := $port.targetPort | default $port.port -}}
                  {{- $ports = append $ports (dict "name" $portName "containerPort" (int $portNumber) "protocol" $portProtocol) -}}
                {{- end -}}
              {{- end -}}
            {{- end -}}
          {{- end -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- if $ports -}}
ports:
  {{- range $port := $ports }}
  - name: {{ $port.name }}
    containerPort: {{ $port.containerPort }}
    protocol: {{ $port.protocol }}
  {{- end }}
{{- end -}}
{{- end -}}