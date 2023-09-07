
local kausal = import 'ksonnet-util/kausal.libsonnet';

local util = import './util.libsonnet';

(import './config.libsonnet') +
{  
  local this = self,
  local k = kausal { _config+:: this._config },
  
  local namespace = k.core.v1.namespace,
  local role = k.rbac.v1.role,
  local roleBinding = k.rbac.v1.roleBinding,
  local serviceAccount = k.core.v1.serviceAccount,
  local policyRule = k.rbac.v1.policyRule,
  
  local config = $._config,

  local labels = util.withLabels(config, config.name),

  namespace: namespace.new(config.namespace) +
    namespace.metadata.withLabelsMixin(util.withLabels(config, config.name)),

  rbac: k.util.namespacedRBAC(
    config.name,
    [
      policyRule.withApiGroups('') +
      policyRule.withResources(['pods', 'pods/exec']) +
      policyRule.withVerbs(['create','delete','get','list','patch','update','watch']),
      policyRule.withApiGroups('') +
      policyRule.withResources(['pods/log', 'events']) +
      policyRule.withVerbs(['get', 'list', 'watch']),
      policyRule.withApiGroups('') +
      policyRule.withResources(['secrets']) +
      policyRule.withVerbs(['get', 'list', 'watch', 'update', 'create', 'delete']),
    ]
  ) + 
  {
    role+: role.metadata.withLabelsMixin(labels),
    role_binding+: roleBinding.metadata.withLabelsMixin(labels),
    service_account+: serviceAccount.metadata.withLabelsMixin(labels),
  }, 

}