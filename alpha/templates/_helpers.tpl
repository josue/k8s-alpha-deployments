{{- define "alpha.name_prefix" -}}
{{- printf "%s-%s-%s" (.Values.prefix | default "alpha") (required "missing .Values.app" .Values.app) (required "missing .Values.commit" .Values.commit | trunc 10) -}}
{{- end -}}

{{- define "alpha.name" -}}
{{- printf "%s-%s" (required "missing .Values.app" .Values.app) (required "missing .Values.commit" .Values.commit | trunc 10) -}}
{{- end -}}

{{- define "namespace" -}}
{{- printf "%s" (.Values.namespace | default "alpha") -}}
{{- end -}}

{{- define "cname" -}}
{{- printf "%s" (.Values.cname | default "alpha.domain.com") -}}
{{- end -}}