local util = import '../util.libsonnet';
local xtd = import 'github.com/jsonnet-libs/xtd/main.libsonnet';
{
  local config = $._config,
  local secret = $._secret,

  _secret+:: {
    "chat-service-sync"+: {
      access_token: 'XXXXXXXXXXXXXXXX',
      client_id: 'XXXXXXXXXXXXXXXX',
      client_secret: 'XXXXXXXXXXXXXXXX',
    },
  },

  _config+:: {
    local mxDomain = util.getDomain(config.matrixDomain, config.environment),
    chatServiceSync+: {
      config+: {
        logLevel: 'INFO',
        dry: "false",
        projectConfigFile: config.chatServiceSync.volume.project.path + "/project.yaml",
        matrixAPI: {
          baseUrl: 'http://synapse',
          accessToken: secret["chat-service-sync"].access_token,
          matrixDomain: mxDomain,
        },
        eclipseAPI: {
          userAPIBaseUrl: 'https://api.eclipse.org',
          projectAPIBaseUrl: 'https://projects.eclipse.org',
          oauth: {
            client: {
              id: secret["chat-service-sync"].client_id,
              secret: secret["chat-service-sync"].client_secret,
            },
            auth: {
              tokenHost: 'https://accounts.eclipse.org',
              tokenPath: '/oauth2/token',
            },
          },
          additionnalOauth: {
            timeout: 3600,
            scope: 'eclipsefdn_view_all_profiles',
          },
        },
      },
      project+: {
        default: {
          users: [
            {
              '@sebastien.heurtematte': 100,
            },
            {
              '@ef_moderator_bot': 60,
            },
          ],
          defaultProjectSpace: '#eclipse-projects',
          userPowerLevel: 50,
          roomPowerLevel: {
            ban: 50,
            events: {
              'm.reaction': 0,
              'm.room.avatar': 55,
              'm.room.canonical_alias': 55,
              'm.room.encryption': 100,
              'm.room.history_visibility': 100,
              'm.room.name': 55,
              'm.room.pinned_events': 50,
              'm.room.power_levels': 100,
              'm.room.redaction': 0,
              'm.room.server_acl': 60,
              'm.room.tombstone': 100,
              'm.room.topic': 50,
              'm.space.child': 55,
              'org.matrix.msc3401.call': 50,
              'org.matrix.msc3401.call.member': 50,
            },
            events_default: 0,
            historical: 100,
            invite: 50,
            kick: 50,
            redact: 50,
            state_default: 50,
            users_default: 0,
          },
        },
        projects: null,
      },
    },
  },
}
