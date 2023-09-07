local util = import '../util.libsonnet';

{
  _config+:: {    
    local config = self,
    appserviceSlack+: {
      local deployment = self,
      local volume = self.volume,
      active:true,
      name: 'appservice-slack',
      shortName: 'asslack',
      host: util.getDomain(config.appserviceSlackDomain, config.environment),
      path: '/',
      version: 'release-2.1.2',
      image: 'docker.io/matrixdotorg/matrix-appservice-slack:' + self.version,
      replicas: 1,
      imagePullPolicy: 'Always',
      containerPort: config.appserviceSlack.appservice.homeserver.appservice_port,
      env+: {},
      resources+: {
        cpuRequest: '250m',
        cpuLimit: '1000m',
        memoryRequest: '250Mi',
        memoryLimit: '1000Mi',
      },
      probe+: {
        readiness+: {
          path: '/health',
          initialDelaySeconds: 10,
          periodSeconds: 60,
          failureThreshold: 3,
          timeoutSeconds: 10,
        },
        liveness+: {
          path: '/health',
          initialDelaySeconds: 120,
          periodSeconds: 120,
          failureThreshold: 3,
          timeoutSeconds: 10,
        },
      },
      volume+: {
        data+: {
          path: '/data',
        }, 
        config+: {
          path: '/config',
        }, 
        registration+: {
          path: '/registration',
        }, 
      }
    },
  },

}
