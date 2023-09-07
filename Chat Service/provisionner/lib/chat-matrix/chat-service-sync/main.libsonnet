
local kausal = import 'ksonnet-util/kausal.libsonnet';
local util = import '../util.libsonnet';

(import '../config.libsonnet') +
(import './config-chat-service-sync.libsonnet') +
(import './config-app.libsonnet') +
{  
  local this = self,
  local k = kausal { _config+:: this._config },
  
  local container = k.core.v1.container,
  local containerPort = k.core.v1.containerPort,
  local secret = k.core.v1.secret,  
  local statefulSet = k.apps.v1.statefulSet,
  local deployment = k.apps.v1.deployment,
  local volumeMount = k.core.v1.volumeMount,
  local volume = k.core.v1.volume,
  local persistentVolume = k.core.v1.persistentVolume,
  local persistentVolumeClaimSpec = k.core.v1.persistentVolumeClaimSpec,
  local persistentVolumeClaim = k.core.v1.persistentVolumeClaim,
  local service = k.core.v1.service,
  local servicePort = k.core.v1.service.mixin.spec.portsType,
  local cronJob = k.batch.v1.cronJob,
  local envFrom = k.core.v1.envFromSource,

  local config = $._config.chatServiceSync,
  local labels = util.withLabels($._config, config.name),
  local namespace = $._config.namespace,

  chatServiceSync:{

    local tokenName = config.name + '-token',
    [ if config.active then 'chatServiceSyncToken'] : util.secretData(tokenName, namespace, labels, config.envFromSecret), 

    local configName = config.name + '-config',   
    [ if config.active then 'chatServiceSyncConfig']: util.configMap(configName, namespace, labels, config.envFromConfigmap),

    local projectName = config.name + '-project',   
    [ if config.active then 'project.yaml']: util.configMap(projectName, namespace, labels, 
      {'project.yaml': std.manifestYamlDoc(config.project, indent_array_in_object=true, quote_keys=false)}
    ),

    container:: util.defaultContainer(config) +
      // container.withCommand(['sh', '-c','sleep 5000']) +
      container.withEnvFrom([
        envFrom.secretRef.withName(tokenName),
        envFrom.configMapRef.withName(configName)
      ]),

    [if config.active then 'cronjob']: util.batch(config, namespace, labels, self.container) +
      cronJob.spec.jobTemplate.spec.template.spec.withRestartPolicy(config.restartPolicy) + 
      cronJob.spec.jobTemplate.spec.withBackoffLimit(config.backoffLimit) +
      cronJob.spec.withSuccessfulJobsHistoryLimit(config.successfulJobsHistoryLimit) +
      cronJob.configVolumeMount(projectName, config.volume.project.path),
  },  
}