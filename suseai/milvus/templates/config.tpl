{{- define "milvus.config" -}}
# Copyright (C) 2019-2021 Zilliz. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance
# with the License. You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
# or implied. See the License for the specific language governing permissions and limitations under the License.

etcd:
{{- if .Values.externalEtcd.enabled }}
  endpoints:
  {{- range .Values.externalEtcd.endpoints }}
    - {{ . }}
  {{- end }}
{{- else }}
  endpoints:
{{- if contains .Values.etcd.name .Release.Name }}
    - {{ .Release.Name }}:{{ .Values.etcd.service.ports.client }}
{{- else }}
    - {{ .Release.Name }}-{{ .Values.etcd.name }}:{{ .Values.etcd.service.ports.client }}
{{- end }}
{{- end }}

metastore:
  type: etcd

{{- if and (.Values.externalS3.enabled) (eq .Values.externalS3.cloudProvider "azure") }}
common:
  storageType: remote
{{- end }}

minio:
{{- if .Values.externalS3.enabled }}
  address: {{ .Values.externalS3.host }}
  port: {{ .Values.externalS3.port }}
  accessKeyID: {{ .Values.externalS3.accessKey }}
  secretAccessKey: {{ .Values.externalS3.secretKey }}
  useSSL: {{ .Values.externalS3.useSSL }}
  bucketName: {{ .Values.externalS3.bucketName }}
  rootPath: {{ .Values.externalS3.rootPath }}
  useIAM: {{ .Values.externalS3.useIAM }}
  cloudProvider: {{ .Values.externalS3.cloudProvider }}
  iamEndpoint: {{ .Values.externalS3.iamEndpoint }}
  region: {{ .Values.externalS3.region }}
  useVirtualHost: {{ .Values.externalS3.useVirtualHost }}
{{- else }}
{{- if contains .Values.minio.name .Release.Name }}
  address: {{ .Release.Name }}
{{- else }}
  address: {{ .Release.Name }}-{{ .Values.minio.name }}
{{- end }}
  port: {{ .Values.minio.service.port }}
  accessKeyID: {{ .Values.minio.rootUser }}
  secretAccessKey: {{ .Values.minio.rootPassword }}
  useSSL: {{ .Values.minio.tls.enabled }}
{{- end }}

{{- if .Values.externalPulsar.enabled }}

mq:
  type: pulsar

messageQueue: pulsar

pulsar:
  address: {{ .Values.externalPulsar.host }}
  port: {{ .Values.externalPulsar.port }}
  maxMessageSize: {{ .Values.externalPulsar.maxMessageSize }}
  tenant: "{{ .Values.externalPulsar.tenant }}"
  namespace: {{ .Values.externalPulsar.namespace }}
  authPlugin: {{ .Values.externalPulsar.authPlugin }}
  authParams: {{ .Values.externalPulsar.authParams }}
{{- end }}

{{- if .Values.externalKafka.enabled }}

mq:
  type: kafka

messageQueue: kafka

kafka:
  brokerList: {{ .Values.externalKafka.brokerList }}
  securityProtocol: {{ .Values.externalKafka.securityProtocol }}
  saslMechanisms: {{ .Values.externalKafka.sasl.mechanisms }}
{{- if .Values.externalKafka.sasl.username }}
  saslUsername: {{ .Values.externalKafka.sasl.username }}
{{- end }}
{{- if .Values.externalKafka.sasl.password }}
  saslPassword: {{ .Values.externalKafka.sasl.password }}
{{- end }}
{{- else if .Values.kafka.enabled }}

mq:
  type: kafka

messageQueue: kafka

kafka:
{{- if contains .Values.kafka.name .Release.Name }}
  brokerList: {{ .Release.Name }}-broker:{{ .Values.kafka.containerPorts.client }}
{{- else }}
  brokerList: {{ .Release.Name }}-{{ .Values.kafka.name }}-broker:{{ .Values.kafka.containerPorts.client }}
{{- end }}
{{- end }}

{{- if not .Values.cluster.enabled }}
{{- if or (eq .Values.standalone.messageQueue "rocksmq") (eq .Values.standalone.messageQueue "natsmq") }}

mq:
  type: {{ .Values.standalone.messageQueue }}

messageQueue: {{ .Values.standalone.messageQueue }}
{{- end }}
{{- end }}

rootCoord:
{{- if .Values.cluster.enabled }}
  address: {{ template "milvus.rootcoord.fullname" . }}
{{- else }}
  address: localhost
{{- end }}
  port: {{ .Values.rootCoordinator.service.port }}
  enableActiveStandby: {{ template "milvus.rootcoord.activeStandby" . }}  # Enable rootcoord active-standby

proxy:
  port: 19530
  internalPort: 19529

queryCoord:
{{- if .Values.cluster.enabled }}
  address: {{ template "milvus.querycoord.fullname" . }}
{{- else }}
  address: localhost
{{- end }}
  port: {{ .Values.queryCoordinator.service.port }}

  enableActiveStandby: {{ template "milvus.querycoord.activeStandby" . }}  # Enable querycoord active-standby

queryNode:
  port: 21123
{{- if .Values.cluster.enabled }}
  enableDisk: {{ .Values.queryNode.disk.enabled }} # Enable querynode load disk index, and search on disk index
{{- else }}
  enableDisk: {{ .Values.standalone.disk.enabled }} # Enable querynode load disk index, and search on disk index
{{- end }}

indexCoord:
{{- if .Values.cluster.enabled }}
  address: {{ template "milvus.indexcoord.fullname" . }}
{{- else }}
  address: localhost
{{- end }}
  port: {{ .Values.indexCoordinator.service.port }}
  enableActiveStandby: {{ template "milvus.indexcoord.activeStandby" . }}  # Enable indexcoord active-standby

indexNode:
  port: 21121

{{- if .Values.cluster.enabled }}
  enableDisk: {{ .Values.indexNode.disk.enabled }} # Enable index node build disk vector index
{{- else }}
  enableDisk: {{ .Values.standalone.disk.enabled }} # Enable index node build disk vector index
{{- end }}

dataCoord:
{{- if .Values.cluster.enabled }}
  address: {{ template "milvus.datacoord.fullname" . }}
{{- else }}
  address: localhost
{{- end }}
  port: {{ .Values.dataCoordinator.service.port }}
  enableActiveStandby: {{ template "milvus.datacoord.activeStandby" . }}  # Enable datacoord active-standby

dataNode:
  port: 21124

log:
  level: {{ .Values.log.level }}
  file:
{{- if .Values.log.persistence.enabled }}
    rootPath: "{{ .Values.log.persistence.mountPath }}"
{{- else }}
    rootPath: ""
{{- end }}
    maxSize: {{ .Values.log.file.maxSize }}
    maxAge: {{ .Values.log.file.maxAge }}
    maxBackups: {{ .Values.log.file.maxBackups }}
  format: {{ .Values.log.format }}

{{- end }}
