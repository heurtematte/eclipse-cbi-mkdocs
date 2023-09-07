local util = import '../util.libsonnet';

{
  local secret = $._secret,
  _secret+:: {
    appservice+: {
      asToken: "XXXXXXXXXXXXXXXX",
      hsToken: "YYYYYYYYYYYYYYYY",
    }
  },
  _config+:: {    
    local config = self,
    local mxDomain = util.getDomain(config.matrixDomain, config.environment),
    appservicePolicies+: {
      appservice+: {
        logLevel: "INFO",
        bindAddress: "0.0.0.0",
        port: 9000,
        homeserverName: mxDomain,
        homeserverUrl: 'http://synapse',
        asToken: secret.appservice.asToken,
        hsToken: secret.appservice.hsToken,
        botName: "EF_policy_bot",
        namespace: null,
        serverNoticesBot: "eclipsewebmaster",
        joinRoomAlias: "Eclipse Foundation Policy Bot",
        joinMessage:"You've just joined `roomAlias`. To continue using Chat Service at Eclipse Foundation you must review and agree to the terms and conditions at https://" + self.homeserverName + "/_matrix/consent",
        directMessage: "false",
        skipMessage: "false",
        excludeJoinMessageRegex: "[\"ef_moderator_bot\",\"ef_sync_bot\",\"ef_slack_bridge_bot\",\"slack_\"]",
        dataPath: "/storage"
      },
    }
  },

}
