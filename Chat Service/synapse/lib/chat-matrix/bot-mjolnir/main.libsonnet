
local kausal = import 'ksonnet-util/kausal.libsonnet';

local util = import '../util.libsonnet';

(import '../config.libsonnet') +
(import './config-bot.libsonnet') +
(import './config-bot-mjolnir.libsonnet') +
{  
  local this = self,
  local k = kausal { _config+:: this._config },
  
  local container = k.core.v1.container,
  local envFrom = k.core.v1.envFromSource,
  local containerPort = k.core.v1.containerPort,
  local servicePort = k.core.v1.servicePort,
  local service = k.core.v1.service,
  local deployment = k.apps.v1.deployment,

  local config = $._config.botMjolnir,
  
  local labels = util.withLabels($._config, config.name),
  local namespace = $._config.namespace,

  botMjolnir: {

    local configName = config.name + '-config',
    conf: util.secretStringData(configName, namespace, labels,
      {['default.yaml']: std.manifestYamlDoc(config.mjolnir, indent_array_in_object=true, quote_keys=false)}),

    [ if config.active then 'persistentVolumeClaim']: util.persistentVolumeClaim(config, namespace, labels),

    container:: util.defaultContainer(config) +
      // container.withCommand(['sh', '-c','printenv'])  +
      container.withPortsMixin(containerPort.new('internal-port', config.containerPortInternal)) +
      util.withHttpProbeContainer(container, config, config.containerPortInternal),
    
    [ if config.active then 'deployment']: util.deployment(config, namespace, labels, self.container) +
      deployment.pvcVolumeMount(config.name + '-pvc', config.volume.data.path) +
      deployment.secretVolumeMount(configName, config.volume.config.path, volumeMountMixin={readOnly: true}),
    
    externalServicePort::servicePort.newNamed(
        name='mjornil-port-svc',
        port=80,
        targetPort='mjornil-port'
      ),
    internalServicePort::servicePort.newNamed(
        name='interal-port-svc',
        port=81,
        targetPort='internal-port'
      ),

    [ if config.active then 'service']: util.service(self.deployment, namespace, labels) +
      service.spec.withPorts([self.externalServicePort, self.internalServicePort]),
    
    [ if config.active then 'route']: util.route(config, namespace, labels),
  },
}