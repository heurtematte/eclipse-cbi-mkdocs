local util = import '../util.libsonnet';
{
  _config+:: {    
    local config = self,
    matrixMediaRepo+: {
      local deployment = self,
      local volume = self.volume,
      active:true,
      name: 'matrix-media-repo',
      shortName: 'mediarepo',
      host: util.getDomain(config.matrixMediaRepoDomain, config.environment),
      path: '/',
      image: 'docker.io/eclipsecbi/matrix-media-repo:latest',
      replicas: 1,
      imagePullPolicy: 'Always',
      containerPort: 8000,
      containerPortService: 80,
      containerPortMetrics: 9000,
      containerPortMetricsService: 90,
      env+: {
        REPO_CONFIG: deployment.volume.config.path
      },
      resources+: {
        cpuRequest: '250m',
        cpuLimit: '1000m',
        memoryRequest: '250Mi',
        memoryLimit: '1000Mi',
      },
      probe+: {
        local probePath = '/healthz',
        readiness+: {
          path: probePath,
          initialDelaySeconds: 10,
          periodSeconds: 3,
          failureThreshold: 3,
          timeoutSeconds: 10,
        },
        liveness+: {
          path: probePath,
          initialDelaySeconds: 30,
          periodSeconds: 10,
          failureThreshold: 3,
          timeoutSeconds: 10,
        },
      },
      volume+: {
        config+: {
          path: '/data/config',
        },
        secret+: {
          path: '/data/secrets',
        },
        media+: {
          path: '/var/matrix/media',
        },
      },
    },
  },
}
