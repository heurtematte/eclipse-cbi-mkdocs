(import 'chat-matrix/main.libsonnet') +
(import '.secrets/secrets.jsonnet') +
{
  _config+:: {
    local config = self,
    environment: 'dev-federation',    
    matrixDomain: 'matrix.eclipsecontent.org',
    chatDomain: 'chat.eclipsecontent.org',
    synapse+: {
      dnsPolicy: 'None',
      dnsConfig:{
        nameServers: ['1.1.1.1', '10.50.0.10'],
        searches: ['chat-matrix-dev.svc.cluster.local', 'svc.cluster.local', 'cluster.local'],
        options: {name: 'ndots', value:'4'}
      },
      logconfig+: {        
        root+: {
          level: 'INFO',
        },
        // loggers+: {
        //   synapse: {
        //     level: 'INFO',
        //   },
        //   'synapse.storage': {
        //     level: 'INFO',
        //   },
        //   'synapse.handlers.oidc': {
        //     level: 'DEBUG',
        //   },
        // }
      },
      homeserver+: {        
        enable_registration: true,
        oidc_providers_idp_icon_id::'55b53e24446e3dc22f8f964718bc192adbee0698',
        database: {
          name: 'sqlite3',
          args: {
            database: '/synapse/data/homeserver.db',
          },
        },
        password_config: {
          enabled: true,
        },
        oidc_providers: [],

      },
    },
    matrixMediaRepo+: {
      active:false,
    },
    synapseAdmin+:{
      active:false,
    },
  },
}
