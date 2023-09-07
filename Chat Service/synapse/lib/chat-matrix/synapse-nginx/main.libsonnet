
local kausal = import 'ksonnet-util/kausal.libsonnet';

local util = import '../util.libsonnet';

(import '../config.libsonnet') +
(import './config-synapse-nginx.libsonnet') +
{  
  local this = self,
  local k = kausal { _config+:: this._config },
  
  local config = $._config.synapseNginx,
  local deployment = k.apps.v1.deployment,
  local configMap = k.core.v1.configMap,
  
  local labels = util.withLabels($._config, config.name),
  local namespace = $._config.namespace,

  synapseNginx: {
    local configName = config.name + '-config',
    [ if config.active then 'config']: 
      util.configMap(configName, namespace, labels, {["default.conf"]: importstr './default.conf'}
    ),

    [ if config.active then 'deployment']: 
      util.deployment(config, namespace, labels) +   
        deployment.configVolumeMount(
          configName, 
          config.volume.config.path
        ),

    // [ if config.active then 'deployment']: util.deployment(config, namespace, labels),  
    [ if config.active then 'service']: util.service(self.deployment, namespace, labels),
  },
}