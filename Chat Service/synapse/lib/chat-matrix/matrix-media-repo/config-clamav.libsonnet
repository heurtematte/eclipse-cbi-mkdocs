local util = import '../util.libsonnet';
{
  _config+:: {    
    local config = self,
    clamav+: {
      active:true,
      name: 'clamav',
      shortName: 'clamav',
      image: 'heurtemattes/clamav:latest',
      imagePullPolicy: 'Always',
      restartPolicy: 'Never',
      successfulJobsHistoryLimit: 3,
      //schedule: '0 0 * * *', #Run once a day at midnight
      schedule: '*/10 * * * *', #Run every 10min
      containerPort: 3310,
      containerProtocol: 'TCP',
      env+: {
        'SCAN_DIRS': '/var/matrix/media'
      },
      resources+: {
        cpuRequest: '250m',
        cpuLimit: '2000m',
        memoryRequest: '250Mi',
        memoryLimit: '2000Mi',
      },
    },
  },
}
