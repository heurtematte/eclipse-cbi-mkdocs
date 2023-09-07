local util = import '../util.libsonnet';

{
  _config+:: {    
    local config = self,
    botMjolnir+: {
      local deployment = self,
      local volume = self.volume,
      active:true,
      name: 'bot-mjolnir',
      shortName: 'mjornil',
      host: util.getDomain(config.mjolnirDomain, config.environment),
      path: '/',
      image: 'docker.io/matrixdotorg/mjolnir:latest',
      replicas: 1,
      imagePullPolicy: 'Always',
      // containerPort: config.botMjolnir.mjolnir.health.healthz.port,
      // containerPortReportProxy: config.botMjolnir.mjolnir.web.port,
      containerPort: config.botMjolnir.mjolnir.web.port,
      containerPortInternal: config.botMjolnir.mjolnir.health.healthz.port,
      env+: {
        NODE_CONFIG_DIR: volume.config.path
      },
      resources+: {
        cpuRequest: '250m',
        cpuLimit: '1000m',
        memoryRequest: '250Mi',
        memoryLimit: '1000Mi',
      },
      probe+: {
        local probePath = '/healthz',
        // readiness+: {
        //   path: probePath,
        //   initialDelaySeconds: 10,
        //   periodSeconds: 3,
        //   failureThreshold: 3,
        //   timeoutSeconds: 10,
        // },
        liveness+: {
          path: probePath,
          initialDelaySeconds: 120,
          periodSeconds: 10,
          failureThreshold: 3,
          timeoutSeconds: 10,
        },
      },
      volume+: {
        data+: {
          path: '/storage',
        },
        config+: {
          path: '/config',
        },
      },
    },
  },

}
