local util = import '../util.libsonnet';

(import '../appservice-policies/config-appservice.libsonnet') +
{
  _config+:: {
    local config = self,

    synapse+: {
      appservicePolicies+: {
        id: 'appservice_policies',
        url: 'http://appservice-policies' ,
        as_token: config.appservicePolicies.appservice.asToken,
        hs_token: config.appservicePolicies.appservice.hsToken,
        sender_localpart: config.appservicePolicies.appservice.botName,
        namespaces: {
          users: [
            {
              exclusive: false,
              regex: '^(?!.*'+ config.appservicePolicies.appservice.serverNoticesBot +'|.*slack_).*$',
            },
          ],
          rooms: [],
          aliases: [],
        },

      },
    },
  },
}
