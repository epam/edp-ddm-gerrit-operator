{{/*
Expand the name of the chart.
*/}}
{{- define "gerrit-operator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "gerrit-operator.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "gerrit-operator.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "gerrit-operator.metaLabels" -}}
helm.sh/chart: {{ include "gerrit-operator.chart" . }}
{{ include "gerrit-operator.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "gerrit-operator.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gerrit-operator.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "imageRegistry" -}}
{{- if .Values.global.imageRegistry -}}
{{- printf "%s/" .Values.global.imageRegistry -}}
{{- else -}}
{{- end -}}
{{- end }}

{{/*
Define Gerrit URL
*/}}
{{- define "edp.hostnameSuffix" -}}
{{- printf "%s-%s.%s" .Values.cdPipelineName .Values.cdPipelineStageName .Values.dnsWildcard }}
{{- end }}

{{- define "admin-tools.hostname" -}}
{{- printf "admin-tools-%s" (include "edp.hostnameSuffix" .) }}
{{- end }}

{{- define "admin-tools.gerritUrl" -}}
{{- printf "%s%s/%s" "https://" (include "admin-tools.hostname" .) .Values.gerrit.basePath }}
{{- end }}

{{/*
Define Keycloak URL
*/}}
{{- define "keycloak.url" -}}
{{- printf "%s%s" "https://" .Values.keycloak.host }}
{{- end -}}

{{- define "keycloak.realm" -}}
{{- printf "%s-%s" .Release.Namespace .Values.keycloakIntegration.realm }}
{{- end -}}

{{- define "admin-routes.whitelist.cidr" -}}
{{- if .Values.global }}
{{- if .Values.global.whiteListIP }}
{{- .Values.global.whiteListIP.adminRoutes }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "admin-routes.whitelist.annotation" -}}
haproxy.router.openshift.io/ip_whitelist: {{ (include "admin-routes.whitelist.cidr" . | default "0.0.0.0/0") | quote }}
{{- end -}}

{{- define "gerrit.keycloak-secret"}}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace .Values.keycloakIntegration.client.secretName) -}}
{{- if $secret }}
{{- $secret.data.clientSecret }}
{{- else }}
{{- uuidv4 | b64enc }}
{{- end }}
{{- end }}

{{/*
If condition is required to save old CI git user name for existing envs till 1.9.4.
Since new user name is forced by upgrade gerrit-operator to v2.13.5
*/}}
{{- define "gerrit.gitUser" }}
{{- $gitServer := (lookup "v2.edp.epam.com/v1alpha1" "GitServer" .Release.Namespace "gerrit") -}}
{{- if $gitServer }}
{{- $gitServer.spec.gitUser }}
{{ else -}}
edp-ci
{{- end -}}
{{ end -}}

{{/*
Redis
*/}}
{{- define "sentinel.host" -}}
{{- if .Values.sentinel.host }}
{{- .Values.sentinel.host }}
{{- else -}}
rfs-redis-sentinel.{{ .Values.namespace }}.svc
{{- end }}
{{- end }}

{{- define "sentinel.port" -}}
{{- if .Values.sentinel.port }}
{{- .Values.sentinel.port }}
{{- else -}}
26379
{{- end }}
{{- end }}
