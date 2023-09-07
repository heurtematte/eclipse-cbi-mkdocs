local util = import '../util.libsonnet';

{
  _config+:: {    
    local config = self,
    synapseNginx+: {
      local deployment = self,
      local volume = self.volume,
      active:true,
      name: 'synapse-nginx',
      shortName: 'snginx',
      // host: util.getDomain(config.synapseNginxDomain, config.environment),
      path: '/',
      image: 'docker.io/eclipsecbi/nginx-vts',
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
          path: '/etc/nginx/conf.d',
        },
      },
    },
  },

}
