
local kausal = import 'ksonnet-util/kausal.libsonnet';

local util = import '../util.libsonnet';

(import '../config.libsonnet') +
(import './config-appservice.libsonnet') +
(import './config-appservice-slack.libsonnet') +
(import './config-appservice-slack-registration.libsonnet') +
{  
  local this = self,
  local k = kausal { _config+:: this._config },
  
  local container = k.core.v1.container,
  local envFrom = k.core.v1.envFromSource,
  local deployment = k.apps.v1.deployment,

  local config = $._config.appserviceSlack,
  
  local labels = util.withLabels($._config, config.name),
  local namespace = $._config.namespace,
  local service = k.core.v1.service,
  local servicePort = k.core.v1.service.mixin.spec.portsType,

  appserviceSlack: {
  
    // MOVE TO SYNAPSE

    local configName = config.name + '-config',
    conf: util.secretStringData(configName, namespace, labels,
      {['config.yaml']: std.manifestYamlDoc(config.appservice, indent_array_in_object=true, quote_keys=false)}),


    local registrationName = config.name + '-registration',
    registration: util.secretStringData(registrationName, namespace, labels,
      {['slack-registration.yaml']: std.manifestYamlDoc(config.registration, indent_array_in_object=true, quote_keys=false)}),

    container:: util.defaultContainer(config) +
      // https://github.com/matrix-org/matrix-appservice-slack/issues/699
      container.withCommand([ "node", "--trace-warnings", "--unhandled-rejections=warn", "lib/app.js", "-c", "/config/config.yaml" ]) + 
      container.withArgs(['-f', '/registration/slack-registration.yaml']),

      //container.withCommand(["sh", "-c","sleep 5m"]),
      // container.withCommand(['sh', '-c','cat /registration/slack-registration.yaml']) +
      // container.withCommand(['sh', '-c','printenv']),

    [ if config.active then 'deployment']: util.deployment(config, namespace, labels, self.container) +
      // deployment.pvcVolumeMount(config.name + '-pvc', config.volume.registration.path) +
      deployment.secretVolumeMount(configName, config.volume.config.path, volumeMountMixin={readOnly: true}) +
      deployment.secretVolumeMount(registrationName, config.volume.registration.path, volumeMountMixin={readOnly: true}),

    //[ if config.active then 'service']: util.service(self.deployment, namespace, labels),

    [ if config.active then 'service' ]:
      local servicePortExternal = servicePort.newNamed(config.shortName + '-svc', config.containerPort, config.shortName + '-port');

      service.new(config.name, self.deployment.spec.selector.matchLabels, [servicePortExternal]) +
        service.mixin.metadata.withNamespace(namespace) +
        service.mixin.metadata.withLabels(labels),
  },
}