local util = import '../util.libsonnet';

{
  _config+:: {    
    local config = self,
    appservicePolicies+: {
      local deployment = self,
      local volume = self.volume,
      active:true,
      name: 'appservice-policies',
      shortName: 'aspolicies',
      // host: util.getDomain(config.appservicePoliciesDomain, config.environment),
      path: '/',
      image: 'docker.io/eclipsecbi/synapse-appservice-joinevent-message:latest',
      replicas: 1,
      imagePullPolicy: 'Always',
      containerPort: config.appservicePolicies.appservice.port,
      env+: {},
      envFromConfigmap+: {
        APP_JOINEVENT_LOG_LEVEL: config.appservicePolicies.appservice.logLevel,
        APP_JOINEVENT_BIND_ADDRESS: config.appservicePolicies.appservice.bindAddress,
        APP_JOINEVENT_PORT: std.toString(config.appservicePolicies.appservice.port),
        APP_JOINEVENT_HOMESERVER_NAME: config.appservicePolicies.appservice.homeserverName,
        APP_JOINEVENT_HOMESERVER_URL: config.appservicePolicies.appservice.homeserverUrl,
        // APP_JOINEVENT_AS_TOKEN: config.appservicePolicies.appservice.asToken,
        // APP_JOINEVENT_HS_TOKEN: config.appservicePolicies.appservice.hsToken,
        APP_JOINEVENT_BOT_NAME: config.appservicePolicies.appservice.botName,
        [if config.appservicePolicies.appservice.namespace != null then "APP_JOINEVENT_NAMESPACE"]: config.appservicePolicies.appservice.namespace,
        APP_JOINEVENT_SERVER_NOTICES_BOT: config.appservicePolicies.appservice.serverNoticesBot,
        APP_JOINEVENT_ROOM_ALIAS: config.appservicePolicies.appservice.joinRoomAlias,
        APP_JOINEVENT_MESSAGE: config.appservicePolicies.appservice.joinMessage,
        APP_JOINEVENT_DIRECT_MESSAGE: std.toString(config.appservicePolicies.appservice.directMessage),
        APP_JOINEVENT_SKIP_MESSAGE: std.toString(config.appservicePolicies.appservice.skipMessage),
        APP_JOINEVENT_EXCLUDE_JOIN_MESSAGE_REGEX: config.appservicePolicies.appservice.excludeJoinMessageRegex,
        APP_JOINEVENT_DATA_PATH: config.appservicePolicies.appservice.dataPath,
      },
      envFromSecret+: {
        APP_JOINEVENT_AS_TOKEN: std.base64(config.appservicePolicies.appservice.asToken),
        APP_JOINEVENT_HS_TOKEN: std.base64(config.appservicePolicies.appservice.hsToken)
      },
      resources+: {
        cpuRequest: '250m',
        cpuLimit: '1000m',
        memoryRequest: '250Mi',
        memoryLimit: '1000Mi',
      },
      probe+: {
        readiness+: {
          path: '/readyz',
          initialDelaySeconds: 10,
          periodSeconds: 60,
          failureThreshold: 3,
          timeoutSeconds: 10,
        },
        liveness+: {
          path: '/livez',
          initialDelaySeconds: 120,
          periodSeconds: 120,
          failureThreshold: 3,
          timeoutSeconds: 10,
        },
      },
      volume+: {
        data+: {
          path: config.appservicePolicies.appservice.dataPath,
        },
      },
    },
  },

}
