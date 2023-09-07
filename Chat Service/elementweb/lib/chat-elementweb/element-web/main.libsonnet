
local kausal = import 'ksonnet-util/kausal.libsonnet';

local util = import '../util.libsonnet';

(import '../config.libsonnet') +
(import './config-elementweb.libsonnet') +
(import './config-app.libsonnet') +
{  
  local this = self,
  local k = kausal { _config+:: this._config },
  
  local deployment = k.apps.v1.deployment,
  local configMap = k.core.v1.configMap,
  local config = $._config,

  local labels = util.withLabels(config, config.elementweb.name),

  local configKey = 'config.' + util.getDomain(config.chatDomain, config.environment) + '.json',

  config: util.configMap(config.elementweb.name + '-config', config.namespace, labels, 
    {[configKey]: std.manifestJsonEx(config.elementweb.config, '    ')}
  ),

  deployment: util.deployment(config.elementweb, config.namespace, labels) +   
    deployment.configVolumeMount(
      config.elementweb.name + '-config', 
      config.elementweb.volume.config.path + '/'+ configKey,
      {subPath: configKey}
    ),
  
  service: util.service($.deployment, config.namespace, labels),

  route: util.route(config.elementweb, config.namespace, labels),
}