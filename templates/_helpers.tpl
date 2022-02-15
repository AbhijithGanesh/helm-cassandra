{{- define "common.names.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.names.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "workingDirec.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "workingDirec.fullname" -}}
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
{{- define "workingDirec.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "workingDirec.labels" -}}
helm.sh/chart: {{ include "workingDirec.chart" . }}
{{ include "workingDirec.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "workingDirec.selectorLabels" -}}
app.kubernetes.io/name: {{ include "workingDirec.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}



{{- define "cassandra.seeds" -}}
{{- $seeds := list }}
{{- $prename := .Values.metadata.names.stateful_set }}
{{- $postname := .Values.metadata.names.fullname}}
{{- $releaseNamespace := .Values.metadata.release.namespace }}
{{- $clusterDomain := .Values.cluster.clusterDomain }}
{{- $seedCount := .Values.cluster.seedCount | int }}
{{- range $e, $i := until $seedCount }}
{{- $seeds = append $seeds (printf "%s-%d.%s.svc.%s.%s" $prename $i $postname $releaseNamespace $clusterDomain) }}
{{- end }}
{{- range .Values.cluster.extraSeeds }}
{{- $seeds = append $seeds . }}
{{- end }}
{{- join "," $seeds }}
{{- end -}}


{{- define "common.labels.matchLabels" -}}
app.kubernetes.io/name: {{ include "common.names.name" . }}
app.kubernetes.io/instance: {{ .Values.metadata.release.Name }}
{{- end -}}

{{- define "common.labels.standard" -}}
app.kubernetes.io/name: {{ include "common.names.name" . }}
helm.sh/chart: {{ include "common.names.chart" . }}
app.kubernetes.io/instance: {{ .Values.metadata.release.Name }}
app.kubernetes.io/managed-by: {{ .Values.metadata.release.Service }}
{{- end -}}

{{- define "common.tplvalues.render" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

{{- define "cassandra.password"}}
cassandra-password: superuser
{{- end}}

{{- define "cassandra.createTlsSecret" -}}
{{- if and (include "cassandra.tlsEncryption" .) .Values.tls.autoGenerated (not .Values.tls.existingSecret) (not .Values.tlsEncryptionSecretName) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{- define "cassandra.getTlsCertStrFromSecret" }}
    {{- $len := (default 365 .Length) | int -}}
    {{- $ca := "" -}}
    {{- $crt := "" -}}
    {{- $key := "" -}}
    {{- $tlsCert := (lookup "v1" "Secret" .Release.Namespace (printf "%s-%s" (include "common.names.name" .) "crt")).data -}}

    {{- if $tlsCert }}
        {{- $ca = (get $tlsCert "ca.crt" | b64dec) -}}
        {{- $crt = (get $tlsCert "tls.crt" | b64dec) -}}
        {{- $key = (get $tlsCert "tls.keye" | b64dec) -}}
    {{- else -}}
        {{- $caFull := genCA "cassandra-ca" 365 }}
        {{- $fullname := include "common.names.name" . }}
        {{- $releaseNamespace := .Release.Namespace }}
        {{- $clusterDomain := .Values.clusterDomain }}
        {{- $serviceName := include "common.names.name" . }}
        {{- $headlessServiceName := printf "%s-headless" (include "common.names.name" .) }}
        {{- $altNames := list (printf "*.%s.%s.svc.%s" $serviceName $releaseNamespace $clusterDomain) (printf "%s.%s.svc.%s" $serviceName $releaseNamespace $clusterDomain) (printf "*.%s.%s.svc.%s" $headlessServiceName $releaseNamespace $clusterDomain) (printf "%s.%s.svc.%s" $headlessServiceName $releaseNamespace $clusterDomain) "localhost" "127.0.0.1" $fullname }}
        {{- $cert := genSignedCert $fullname nil $altNames 365 $caFull }}
        {{- $ca = $caFull.Cert -}}
        {{- $crt = $cert.Cert -}}
        {{- $key = $cert.Key -}}
    {{- end -}}

    {{- printf "%s###%s###%s" $ca $crt $key -}}
{{- end }}
