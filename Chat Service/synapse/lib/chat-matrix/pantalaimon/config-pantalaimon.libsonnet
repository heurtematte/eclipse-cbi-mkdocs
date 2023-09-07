local util = import '../util.libsonnet';

{
  _config+:: {    
    local config = self,
    pantalaimon+: {
      local deployment = self,
      local volume = self.volume,
      active:true,
      name: 'pantalaimon',
      shortName: 'ptlm',
      path: '/',
      image: 'docker.io/matrixdotorg/pantalaimon:latest',
      replicas: 1,
      imagePullPolicy: 'Always',
      containerPort: config.pantalaimon["pantalaimon.conf"].sections.matrix.ListenPort,
      env+: {},
      resources+: {
        cpuRequest: '250m',
        cpuLimit: '1000m',
        memoryRequest: '250Mi',
        memoryLimit: '1000Mi',
      },
      // probe+: {
      //   local probePath = '/',
      //   readiness+: {
      //     path: probePath,
      //     initialDelaySeconds: 10,
      //     periodSeconds: 3,
      //     failureThreshold: 3,
      //     timeoutSeconds: 10,
      //   },
      //   liveness+: {
      //     path: probePath,
      //     initialDelaySeconds: 120,
      //     periodSeconds: 10,
      //     failureThreshold: 3,
      //     timeoutSeconds: 10,
      //   },
      // },
      volume+: {
        data+: {
          path: '/data',
        },
        config+: {
          path: '/config',
        },
      },
    },
  },

}
