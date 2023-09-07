local util = import '../util.libsonnet';

{
  local secret = $._secret,
  _secret+:: {
    "bot-mjolnir"+: {
      password: 'XXXXXXXXXXXXXXXX',
    },
  },
  _config+:: {
    local config = self,
    local mxDomain = util.getDomain(config.matrixDomain, config.environment),
    botMjolnir+: {
      mjolnir+: {
        homeserverUrl: 'http://pantalaimon',
        rawHomeserverUrl: 'http://synapse',
        accessToken: '',
        pantalaimon: {
          use: true,
          username: 'ef_moderator_bot',
          password: secret["bot-mjolnir"].password,
        },
        dataPath: config.botMjolnir.volume.data.path,
        autojoinOnlyIfManager: true,
        acceptInvitesFromSpace: null,
        recordIgnoredInvites: false,
        managementRoom: '#eclipsefdn.chat-moderation:' + mxDomain,
        verboseLogging: false,
        logLevel: 'INFO',
        syncOnStartup: true,
        verifyPermissionsOnStartup: true,
        noop: false,
        fasterMembershipChecks: false,
        automaticallyRedactForReasons: [
          'spam',
          'advertising',
        ],
        protectedRooms: [],
        protectAllJoinedRooms: true,
        backgroundDelayMS: 500,
        admin: {
          enableMakeRoomAdminCommand: false,
        },
        commands: {
          allowNoPrefix: true,
          additionalPrefixes: [],
          confirmWildcardBan: true,
        },
        protections: {
          wordlist: {
            words: [
            ],
            minutesBeforeTrusting: 0,
          },
        },
        health: {
          healthz: {
            enabled: true,
            port: 8081,
            address: '0.0.0.0',
            endpoint: '/healthz',
            healthyStatus: 200,
            unhealthyStatus: 418,
          },
          sentry: null,
        },
        web: {
          enabled: true,
          port: 8080,
          address: '0.0.0.0',
          abuseReporting: {
            enabled: true,
          },
        },
        pollReports: false,
        displayReports: true,
      },
    },
  },

}
