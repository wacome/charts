{{/* Returns Lowest and Highest ports assigned to any container in the pod */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.helpers.securityContext.getPortRange" (dict "rootCtx" $ "objectData" $objectData) }}
rootCtx: The root context of the chart.
objectData: The object data to be used to render the Pod.
*/}}
{{- define "ix.v1.common.lib.helpers.securityContext.getPortRange" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- $portRange := dict "high" 0 "low" 65535 -}}

  {{- range $name, $service := $rootCtx.Values.service -}}
    {{- if kindIs "map" $service -}}
      {{- $selected := false -}}
      {{/* If service is enabled... */}}
      {{- if hasKey $service "enabled" -}}
        {{- if $service.enabled -}}
          {{/* If there is a selector */}}
          {{- if hasKey $service "targetSelector" -}}
            {{/* And pod is selected */}}
            {{- if eq $service.targetSelector $objectData.shortName -}}
              {{- $selected = true -}}
            {{- end -}}
          {{- else -}}
            {{/* If no selector is defined but pod is primary */}}
            {{- if $objectData.primary -}}
              {{- $selected = true -}}
            {{- end -}}
          {{- end -}}
        {{- end -}}
      {{- end -}}

      {{- if $selected -}}
        {{- range $portName, $portValues := $service.ports -}}
          {{- if kindIs "map" $portValues -}}
            {{- if hasKey $portValues "enabled" -}}
              {{- if $portValues.enabled -}}
                {{- $portToCheck := 0 -}}
                {{- if hasKey $portValues "targetPort" -}}
                  {{- $portToCheck = $portValues.targetPort -}}
                {{- else if hasKey $portValues "port" -}}
                  {{- $portToCheck = $portValues.port -}}
                {{- end -}}

                {{- if kindIs "string" $portToCheck -}}
                  {{- $portToCheck = (tpl $portToCheck $rootCtx) | atoi -}}
                {{- end -}}

                {{- $portToCheck = $portToCheck | int -}}

                {{- if and (gt $portToCheck 0) (lt $portToCheck 65536) -}}
                  {{- $portRange = merge $portRange (dict "high" (max $portRange.high $portToCheck) "low" (min $portRange.low $portToCheck)) -}}
                {{- end -}}
              {{- end -}}
            {{- end -}}
          {{- end -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- $portRange | toJson -}}
{{- end -}}