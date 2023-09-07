
local kausal = import 'ksonnet-util/kausal.libsonnet';

local util = import '../util.libsonnet';

(import '../config.libsonnet') +
(import './config-synapse-admin.libsonnet') +
{  
  local this = self,
  local k = kausal { _config+:: this._config },
  
  local config = $._config.synapseAdmin,
  
  local labels = util.withLabels($._config, config.name),
  local namespace = $._config.namespace,

  synapseAdmin: {
    [ if config.active then 'deployment']: util.deployment(config, namespace, labels),  
    [ if config.active then 'service']: util.service(self.deployment, namespace, labels),
    [ if config.active then 'route']: util.route(config, namespace, labels),
  },
}