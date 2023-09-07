
local kausal = import 'ksonnet-util/kausal.libsonnet';

local util = import '../util.libsonnet';

(import '../config.libsonnet') +
(import './config.libsonnet') +
(import './config-pantalaimon.libsonnet') +
{  
  local this = self,
  local k = kausal { _config+:: this._config },
  
  local container = k.core.v1.container,
  local deployment = k.apps.v1.deployment,
  local volumeMount = k.core.v1.volumeMount,

  local config = $._config.pantalaimon,
  
  local labels = util.withLabels($._config, config.name),
  local namespace = $._config.namespace,

  pantalaimon: {
  
    local configName = config.name + '-config',
    conf: util.secretStringData(configName, namespace, labels, 
      {['pantalaimon.conf']: std.manifestIni(config['pantalaimon.conf'])}
    ),

    [if config.active then 'persistentVolumeClaim']: util.persistentVolumeClaim(config, namespace, labels),

    container::util.defaultContainer(config) +
      //container.withCommand(["sh", "-c","sleep 5m"]),
      container.withCommand(['pantalaimon', '-c', config.volume.config.path + '/pantalaimon.conf', "--data-path", config.volume.data.path]),

    [ if config.active then 'deployment']: util.deployment(config, namespace, labels, self.container) +
      deployment.pvcVolumeMount(config.name + '-pvc', config.volume.data.path) +
      deployment.secretVolumeMount(configName, config.volume.config.path, volumeMountMixin={readOnly: true}),

    [ if config.active then 'service']: util.service(self.deployment, namespace, labels),
  },
}