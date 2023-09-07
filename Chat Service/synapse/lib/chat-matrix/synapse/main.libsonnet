
local kausal = import 'ksonnet-util/kausal.libsonnet';

local util = import '../util.libsonnet';

(import '../config.libsonnet') +
(import './config-synapse.libsonnet') +
(import './config-logconfig.libsonnet') +
(import './config-stats.libsonnet') +
(import './config-homeserver.libsonnet') +
(import './config-appservice-policies.libsonnet') +
(import '../appservice-slack/config-appservice-slack-registration.libsonnet') +
// (import '../appservice-slack/config-appservice-slack.libsonnet') +
// (import '../appservice-slack/config-appservice-slack-registration.libsonnet') +
{  
  local this = self,
  local k = kausal { _config+:: this._config },
  
  local container = k.core.v1.container,
  local containerPort = k.core.v1.containerPort,
  local deployment = k.apps.v1.deployment,
  local configMap = k.core.v1.configMap,
  local secret = k.core.v1.secret,  
  local config = $._config.synapse,
  local configStats = $._config.stats,
  local secrets = $._secret.synapse,
  local service = k.core.v1.service,
  local servicePort = k.core.v1.service.mixin.spec.portsType,
  local route = import '../../okd/networking/route.libsonnet',

  local configSlack = $._config.appserviceSlack,

  local labels = util.withLabels($._config, config.name),
  local namespace = $._config.namespace,

  synapse: {

    local logconfigName = config.name + '-log',
    logconfig: util.configMap(logconfigName, namespace, labels, 
      {[util.getDomain($._config.matrixDomain, $._config.environment) + '.log.config.yaml']: 
        std.manifestYamlDoc(config.logconfig, indent_array_in_object=true, quote_keys=false)}
    ),

    local signingName = config.name + '-keys',
    signing: util.secretData(signingName, namespace, labels, 
      {[util.getDomain($._config.matrixDomain, $._config.environment) + '.signing.key']: std.base64(secrets.signing)}
    ),

    local homeserverName = config.name + '-homeserver',
    homeserver: util.secretStringData(homeserverName, namespace, labels, 
      {'homeserver.yaml': std.manifestYamlDoc(config.homeserver,indent_array_in_object=true, quote_keys=false)}
    ),

    local appservicePoliciesName = config.name + '-appservice-policies',
    appservicePolicies: util.secretStringData(appservicePoliciesName, namespace, labels, 
      {'appservice-policies.yaml': std.manifestYamlDoc(config.appservicePolicies,indent_array_in_object=true, quote_keys=false)}
    ),

    local appserviceSlackName = config.name + '-appservice-slack',
    appserviceSlack: util.secretStringData(appserviceSlackName, namespace, labels, 
      {'appservice-slack.yaml': std.manifestYamlDoc($._config.appserviceSlack.registration,indent_array_in_object=true, quote_keys=false)}
    ),
    
    //container:: util.defaultContainer(config),

    container:: util.defaultContainer(config) +
      // container.withCommand(['sh', '-c','cat /synapse/appservice/appservice-policies.yaml'])  +
      container.withPortsMixin(containerPort.new('synmetrics-port', config.containerPortMetrics)),

    containerstats:: util.defaultContainer(configStats),

    // local slackConfigName = configSlack.name + '-config',
    // slackConf: util.secretStringData(slackConfigName, namespace, labels,
    //   {['config.yaml']: std.manifestYamlDoc(configSlack.appservice, indent_array_in_object=true, quote_keys=false)}),


    // local slackRegistrationName = configSlack.name + '-registration',
    // slackRegistration: util.secretStringData(slackRegistrationName, namespace, labels,
    //   {['slack-registration.yaml']: std.manifestYamlDoc(configSlack.registration, indent_array_in_object=true, quote_keys=false)}),

    // containerslack:: util.defaultContainer(configSlack) +
    //   // https://github.com/matrix-org/matrix-appservice-slack/issues/699
    //   //container.withCommand([ "node", "--trace-warnings", "--unhandled-rejections=warn", "lib/app.js", "-c", "/config/config.yaml" ]) + 
    //   container.withArgs(['-f', '/registration/slack-registration.yaml']),

    deployment: util.deployment(config, namespace, labels, [self.container, self.containerstats]) +   
    //deployment: util.deployment(config, namespace, labels, [self.container, self.containerstats, self.containerslack]) +   
      deployment.emptyVolumeMount(config.name + '-data', config.volume.data.path) +
      deployment.configVolumeMount(logconfigName, config.volume.log.path) +
      deployment.secretVolumeMount(signingName, config.volume.keys.path, volumeMountMixin={readOnly: true}) +
      deployment.secretVolumeMount(homeserverName, config.volume.homeserver.path, volumeMountMixin={readOnly: true}) +
      deployment.secretVolumeMount(appservicePoliciesName, config.volume.appservice.path, volumeMountMixin={readOnly: true}) +
      deployment.secretVolumeMount(appserviceSlackName, config.volume.appserviceslack.path, volumeMountMixin={readOnly: true}),
      // deployment.secretVolumeMount(slackConfigName, configSlack.volume.config.path, volumeMountMixin={readOnly: true}) +
      // deployment.secretVolumeMount(slackRegistrationName, configSlack.volume.registration.path, volumeMountMixin={readOnly: true}),
    
    // service: util.service(self.deployment, namespace, labels),

    local servicePortExternal = servicePort.newNamed(config.shortName + '-svc', config.containerPortService, config.shortName + '-port'),
    local servicePortMetricsExternal = servicePort.newNamed('synmetrics-svc', config.containerPortMetricsService, 'synmetrics-port'),
    service: service.new(config.name, self.deployment.spec.selector.matchLabels, [servicePortExternal, servicePortMetricsExternal]) +
      service.mixin.metadata.withNamespace(namespace) +
      service.mixin.metadata.withLabels(labels),

    route: util.route(config, namespace, labels, disable_cookies='false')
  },
}