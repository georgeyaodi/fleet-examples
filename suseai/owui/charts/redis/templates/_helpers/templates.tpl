{{/*
    Render a set of Helm values into YAML, only if they have a non-empty value. Boolean, integer and float values will always be rendered.
*/}}
{{- define "application-collection.render.values" }}
    {{- $values := default (dict) .values }}
    {{- $keys := default (keys $values) .keys }}
    {{- $omitKeys := default (dict) .omitKeys }}
    {{- $result := dict }}
    {{- range $key := $keys }}
        {{- if or (not $omitKeys) (not (has $key $omitKeys)) }}
            {{- $value := get $values $key }}
            {{- if or $value (kindIs "bool" $value) (kindIs "int" $value) (kindIs "int64" $value) (kindIs "float64" $value) }}
                {{- $_ := set $result $key $value }}
            {{- end }}
        {{- end }}
    {{- end }}
    {{- if $result }}
        {{- $result | toYaml | nindent 0 }}
    {{- end }}
{{- end }}

{{/*
    Render the 'annotations' field into YAML, but only when there is at least one or more defined annotations.
*/}}
{{- define "application-collection.render.annotations" }}
    {{- $annotations := include "application-collection.annotations.list" . | fromYaml }}
    {{- include "application-collection.render.values" (dict "values" (dict "annotations" $annotations)) }}
{{- end }}

{{/*
    Render the 'labels' field into YAML, but only when there is at least one or more defined labels.
*/}}
{{- define "application-collection.render.labels" }}
    {{- $labels := include "application-collection.labels.list" . | fromYaml }}
    {{- include "application-collection.render.values" (dict "values" (dict "labels" $labels)) }}
{{- end }}

{{/*
    Render 'env' fields from an input dictionary, priorizing those environment variables with a 'valueFrom' field.
*/}}
{{- define "application-collection.render.containerEnvValues" }}
    {{- $context := .context }}
    {{- $envValues := .envValues }}
    {{- $result := list }}
    {{- $priorizedEnvVars := list }}
    {{- range $envName, $envValue := $envValues }}
        {{- if and (not (kindIs "string" $envValue)) (eq (include "application-collection.render.boolean" (dict "template" $envValue.enabled "context" $context)) "true") $envValue.valueFrom }}
            {{- $result = append $result (set (omit $envValue "enabled") "name" $envName) }}
            {{- $priorizedEnvVars = append $priorizedEnvVars $envName }}
        {{- end }}
    {{- end }}
    {{- range $envName, $envValue := $envValues }}
        {{- if not (has $envName $priorizedEnvVars) }}
            {{- if kindIs "string" $envValue }}
                {{- $result = append $result (dict "name" $envName "value" $envValue) }}
            {{- else if eq (include "application-collection.render.boolean" (dict "template" $envValue.enabled "context" $context)) "true" }}
                {{- $result = append $result (set (omit $envValue "enabled") "name" $envName) }}
            {{- end }}
        {{- end }}
    {{- end }}
    {{- tpl (include "application-collection.render.values" (dict "omitKeys" (list "enabled") "values" (dict "env" $result))) $context }}
{{- end }}

{{/*
    Render a template with a true/false string value, and convert to a boolean
*/}}
{{- define "application-collection.render.boolean" }}
    {{- $context := .context }}
    {{- $template := .template }}
    {{- if kindIs "bool" $template }}
        {{- $template }}
    {{- else }}
        {{- tpl $template $context }}
    {{- end }}
{{- end }}
