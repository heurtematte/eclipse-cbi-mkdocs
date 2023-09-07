
local kausal = import 'ksonnet-util/kausal.libsonnet';

local util = import '../util.libsonnet';

(import '../config.libsonnet') +
(import './config-appservice.libsonnet') +
(import './config-appservice-policies.libsonnet') +
{  
  local this = self,
  local k = kausal { _config+:: this._config },
  
  local deployment = k.apps.v1.deployment,
  local container = k.core.v1.container,
  local envFrom = k.core.v1.envFromSource,

  local config = $._config.appservicePolicies,
  
  local labels = util.withLabels($._config, config.name),
  local namespace = $._config.namespace,

  appservicePolicies: {
  
    local tokenName = config.name + '-token',
    appserviceToken: util.secretData(tokenName, namespace, labels, config.envFromSecret), 

    local configName = config.name + '-config',   
    appserviceConfig: util.configMap(configName, namespace, labels, config.envFromConfigmap),

    [ if config.active then 'persistentVolumeClaim']: util.persistentVolumeClaim(config, namespace, labels),

    container:: util.defaultContainer(config) +
      container.withEnvFrom([
        envFrom.secretRef.withName(tokenName),
        envFrom.configMapRef.withName(configName)
      ]),

    [ if config.active then 'deployment']: util.deployment(config, namespace, labels, self.container) +
      deployment.pvcVolumeMount(config.name + '-pvc', config.volume.data.path), 
    
    [ if config.active then 'service']: util.service(self.deployment, namespace, labels),
  },
}