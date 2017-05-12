{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "postgresql.fullname" -}}
{{- printf "%s-%s" .Release.Name "postgresql" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified redis name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "redis.fullname" -}}
{{- printf "%s-%s" .Release.Name "redis" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* CUSTOM TEMPLATES */}}

{{/* Environment for Airflow container */}}
{{- define "airflow_env" -}}
- name: LOAD_EX
  value: {{ if .Values.loadExamples }}"y"{{ else }}"n"{{ end }}
- name: EXECUTOR
  value: "Celery"
- name: FERNET_KEY
  valueFrom:
    secretKeyRef:
      name: {{ template "fullname" . }}
      key: fernet-key
- name: POSTGRES_HOST
  value: {{ template "postgresql.fullname" . }}
- name: POSTGRES_USER
  value: {{ .Values.postgresql.postgresUser | quote }}
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ template "postgresql.fullname" . }}
      key: postgres-password
- name: POSTGRES_DB
  value: {{ .Values.postgresql.postgresDatabase | quote }}
- name: REDIS_HOST
  value: {{ template "redis.fullname" . }}
{{ if .Values.redis.usePassword }}
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ template "redis.fullname" . }}
      key: redis-password
{{ end }}
{{- end -}}

{{- define "airflow_dags" -}}
{{ if .Values.dags }}
          volumeMounts:
            - name: dags
              mountPath: /usr/local/airflow/dags
              subPath: {{ default "" .Values.dags.subPath | quote }}
      volumes:
        - name: dags
{{ toYaml .Values.dags.volume | indent 10 }}
{{ end }}
{{- end -}}