local util = import '../util.libsonnet';
{
  _config+:: {    
    local config = self,
    stats+: {
      active:true,
      name: 'synapse-stats',
      shortName: 'synstats',
      image: 'heurtemattes/synapse-stats:latest',
      imagePullPolicy: 'Always',
      restartPolicy: 'Never',
      containerPort: 3000,
      env+: {
      },
      resources+: {
        cpuRequest: '100m',
        cpuLimit: '100m',
        memoryRequest: '100Mi',
        memoryLimit: '100Mi',
      },
    },
  },
}
