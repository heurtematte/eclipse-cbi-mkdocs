
local util = import '../util.libsonnet';

{
  _config+:: {    
    local config = self,
    elementweb+: {
      local deployment = self,
      local volume = self.volume,
      name: 'elementweb',
      shortName: 'elementweb',
      host: util.getDomain(config.chatDomain, config.environment),
      path: '/',
      image: 'docker.io/eclipsecbi/element-web:latest',
      replicas: 1,
      imagePullPolicy: 'Always',
      containerPort: 8080,
      env+: {
      },
      resources+: {
        cpuRequest: '250m',
        cpuLimit: '1000m',
        memoryRequest: '250Mi',
        memoryLimit: '1000Mi',
      },
      probe+: {
        local probePath = '/status',
        readiness+: {
          path: probePath,
          initialDelaySeconds: 2,
          periodSeconds: 3,
          failureThreshold: 3,
          timeoutSeconds: 10,
        },
        liveness+: {
          path: probePath,
          initialDelaySeconds: 10,
          periodSeconds: 10,
          failureThreshold: 3,
          timeoutSeconds: 10,
        },
      },
      volume+: {
        config+: {
          path: '/app',
        },
      },
    },
  },

}
