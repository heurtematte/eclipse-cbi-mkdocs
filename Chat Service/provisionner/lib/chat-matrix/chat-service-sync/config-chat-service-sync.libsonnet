local util = import '../util.libsonnet';

{
  _config+:: {    
    local config = self,
    chatServiceSync+: {
      active:true,
      name: 'chatservice-sync',
      shortName: 'cssync',
      image: 'docker.io/eclipsecbi/chat-service-sync',
      imagePullPolicy: 'Always',
      restartPolicy: 'Never',
      backoffLimit: 0,
      successfulJobsHistoryLimit: 1,
      schedule: '0 * * * *', #every hours
      containerPort: 3000, # fake port, not use
      env+: {
      },
      envFromConfigmap+: {
        SYNC_LOG_LEVEL: config.chatServiceSync.config.logLevel,
        SYNC_DRY: std.toString(config.chatServiceSync.config.dry),
        SYNC_PROJECT_CONFIG_FILE: config.chatServiceSync.config.projectConfigFile,
        SYNC_PERMS_HOMESERVER_URL: config.chatServiceSync.config.matrixAPI.baseUrl,
        SYNC_PERMS_HOMESERVER_DOMAIN: config.chatServiceSync.config.matrixAPI.matrixDomain,
        SYNC_ECLIPSE_USER_API_BASE_URL: config.chatServiceSync.config.eclipseAPI.userAPIBaseUrl,
        SYNC_ECLIPSE_PROJECT_API_BASE_URL: config.chatServiceSync.config.eclipseAPI.projectAPIBaseUrl,
        SYNC_ECLIPSE_API_OAUTH_AUTH_TOKEN_HOST: config.chatServiceSync.config.eclipseAPI.oauth.auth.tokenHost,
        SYNC_ECLIPSE_API_OAUTH_AUTH_TOKEN_PATH: config.chatServiceSync.config.eclipseAPI.oauth.auth.tokenPath,
        SYNC_ECLIPSE_API_ADDITIONNALOAUTH_TIMEOUT: std.toString(config.chatServiceSync.config.eclipseAPI.additionnalOauth.timeout),
        SYNC_ECLIPSE_API_ADDITIONNALOAUTH_SCOPE: config.chatServiceSync.config.eclipseAPI.additionnalOauth.scope,
      },
      envFromSecret+: {
        SYNC_PERMS_HOMESERVER_TOKEN: std.base64(config.chatServiceSync.config.matrixAPI.accessToken),
        SYNC_ECLIPSE_API_OAUTH_CLIENT_ID: std.base64(config.chatServiceSync.config.eclipseAPI.oauth.client.id),
        SYNC_ECLIPSE_API_OAUTH_SECRET: std.base64(config.chatServiceSync.config.eclipseAPI.oauth.client.secret),
      },
      resources+: {
        cpuRequest: '250m',
        cpuLimit: '1000m',
        memoryRequest: '250Mi',
        memoryLimit: '1000Mi',
      },
      volume+: {
        project+: {
          path: '/data',
        }, 
      }
    }
  }
}
