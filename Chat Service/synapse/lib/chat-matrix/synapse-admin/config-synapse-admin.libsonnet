local util = import '../util.libsonnet';

{
  _config+:: {    
    local config = self,
    synapseAdmin+: {
      local deployment = self,
      local volume = self.volume,
      active:true,
      name: 'synapse-admin',
      shortName: 'sadmin',
      host: util.getDomain(config.synapseAdminDomain, config.environment),
      path: '/',
      image: 'docker.io/eclipsecbi/synapse-admin:' + config.environment,
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
        local probePath = '/',
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
    },
  },

}
