
local kausal = import 'ksonnet-util/kausal.libsonnet';
local util = import '../util.libsonnet';

(import '../config.libsonnet') +
(import './config-media-repo.libsonnet') +
(import './config-clamav.libsonnet') +
(import './config-app-media-repo.libsonnet') +
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

  local config = $._config.matrixMediaRepo,
  local clamav = $._config.clamav,
  local labels = util.withLabels($._config, config.name),
  local namespace = $._config.namespace,

  matrixMediaRepo:{
    [ if config.active then 'mediarepo.yaml']: util.secretStringData(config.name + '-secret', namespace, labels, 
      {'mediarepo.yaml': std.manifestYamlDoc(config.mediarepo, indent_array_in_object=true, quote_keys=false)}
    ),

    container:: if config.active then util.defaultContainer(config) +
      container.withPortsMixin(containerPort.new('metrics-port', config.containerPortMetrics)) +
      container.withCommand(['sh', '-c',
        '(
          while true; do
            cp -u ' + config.volume.secret.path + '/* '+ config.volume.config.path + '/
            sleep 30
          done
        ) &
        media_repo']),

    clamavContainer:: if clamav.active then util.defaultContainer(clamav)+
      container.withVolumeMounts(volumeMount.new(config.name + '-pvc', config.volume.media.path)) + 
      container.withCommand(['sh', '-c','clamav-scan']) ,
      //  container.withCommand(["sh", "-c","sleep 5m"]),
     //std.prune([self.container, self.clamav])

    [if clamav.active then 'clamav-cronjob']: util.batch(clamav, namespace, labels, self.clamavContainer) +
      cronJob.spec.jobTemplate.spec.template.spec.withRestartPolicy(clamav.restartPolicy) + 
      cronJob.spec.withSuccessfulJobsHistoryLimit(clamav.successfulJobsHistoryLimit) + 
      cronJob.spec.jobTemplate.spec.template.spec.withVolumes(volume.fromPersistentVolumeClaim(config.name + '-pvc', config.name + '-pvc')),

    [if config.active then 'persistentVolumeClaim']: util.persistentVolumeClaim(config, namespace, labels),

    [if config.active then 'deployment']: util.deployment(config, namespace, labels, self.container) +
      deployment.emptyVolumeMount(config.name + "-config", config.volume.config.path) +
      deployment.secretVolumeMount(config.name + '-secret', config.volume.secret.path, volumeMountMixin={readOnly: true}) +
      deployment.pvcVolumeMount(config.name + '-pvc', config.volume.media.path),

    [if config.active then 'service']:
      local servicePortExternal = servicePort.newNamed('mediarepo-svc', config.containerPortService, 'mediarepo-port');
      local servicePortInternal = servicePort.newNamed('metrics-svc', config.containerPortMetricsService, 'metrics-port');

      service.new(config.name, self.deployment.spec.selector.matchLabels, [servicePortExternal, servicePortInternal]) +
        service.mixin.metadata.withNamespace(namespace) +
        service.mixin.metadata.withLabels(labels),

    [if config.active then 'route']: util.route(config, namespace, labels),
  },  
}