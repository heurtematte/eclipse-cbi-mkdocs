
local util = import '../util.libsonnet';

{
  _config+:: {    
    local config = self,
    synapse+: {
      local deployment = self,
      local volume = self.volume,
      name: 'synapse',
      shortName: 'synapse',
      host: util.getDomain(config.matrixDomain, config.environment),
      path: '/',
      version:"latest",
      image: 'docker.io/eclipsecbi/synapse:' + self.version,
      replicas: 1,
      imagePullPolicy: 'Always',
      containerPort: 8008,
      containerPortMetrics: 9008,
      containerStatMetrics: 3000,
      containerPortService: 80,
      containerPortMetricsService: 90,
      // dnsPolicy: 'None',
      // dnsConfig:{
      //   nameServers: ['10.50.0.10'],
      //   searches: ['chat-matrix-dev.svc.cluster.local', 'svc.cluster.local', 'cluster.local'],
      //   options: {name: 'ndots', value:5}
      // },
      env+: {
        SYNAPSE_SERVER_NAME: deployment.host,
        SYNAPSE_CONFIG_PATH: volume.homeserver.path + '/homeserver.yaml',
        SYNAPSE_CACHE_FACTOR: '2.0',
        SYNAPSE_LOG_LEVEL: 'INFO',
      },
      resources+: {
        cpuRequest: '1000m',
        cpuLimit: '2000m',
        memoryRequest: '250Mi',
        memoryLimit: '1000Mi',
      },
      probe+: {
        local probePath = '/_matrix/client/versions',
        readiness+: {
          path: probePath,
          initialDelaySeconds: 10,
          periodSeconds: 3,
          failureThreshold: 3,
          timeoutSeconds: 10,
        },
        liveness+: {
          path: probePath,
          initialDelaySeconds: 120,
          periodSeconds: 10,
          failureThreshold: 3,
          timeoutSeconds: 10,
        },
      },
      volume+: {
        local volume = self,
        local rootMountPath = '/synapse',
        data+: {
          path: rootMountPath + '/data',
        },
        keys+: {
          path: rootMountPath + '/keys',
        },
        homeserver+: {
          path: rootMountPath + '/config',
        },
        appservice+: {
          path: rootMountPath + '/appservice',
        },
        appserviceslack+: {
          path: rootMountPath + '/appserviceslack',
        },
        log+: {
          path: rootMountPath + '/log',
        },
      },
    },
  },
}
