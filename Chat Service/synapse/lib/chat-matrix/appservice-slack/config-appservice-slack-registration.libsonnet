local util = import '../util.libsonnet';

(import './config-appservice.libsonnet') +
{
  local secret = $._secret,
  _secret+:: {
    "matrix-appservice-slack"+: {
      asToken: "XXXXXXXXXXXXXXXX",
      hsToken: "YYYYYYYYYYYYYYYY",
      database_password: "XXXXXXXXXXXXXXXX"
    }
  },

  _config+:: {
    local config = self,
    local mxDomain = util.getDomain(config.matrixDomain, config.environment),

    appserviceSlack+: {
      registration+: {
        id: 'appservice_slack',
        url: 'http://appservice-slack:5858',
        // url: 'http://localhost:5858',
        as_token: secret["matrix-appservice-slack"].asToken, 
        hs_token: secret["matrix-appservice-slack"].hsToken,
        sender_localpart: "ef_slack_bridge_bot",
        namespaces: {
          users: [
            {
              exclusive: true,
              regex: '@'+ config.appserviceSlack.appservice.username_prefix +'.*:' + mxDomain,
            },
          ]
        },
      },
    },
  },
}
