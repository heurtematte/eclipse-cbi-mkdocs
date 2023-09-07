(import 'chat-matrix/main.libsonnet') +
(import '.secrets/secrets.jsonnet') +
{
  _config+:: {
    local config = self,
    environment: 'dev',
    matrixDomain: 'matrix.eclipsecontent.org',
    chatDomain: 'chat.eclipsecontent.org',
    synapse+: {
      // dnsPolicy: 'None',
      // dnsConfig:{
      //   nameServers: ['10.50.0.10'],
      //   searches: ['chat-matrix-dev.svc.cluster.local', 'svc.cluster.local', 'cluster.local'],
      //   options: {name: 'ndots', value:'4'}
      // },
      logconfig+: {        
        root+: {
          level: 'DEBUG',
        },
        loggers+: {
          synapse: {
            level: 'INFO',
          },
          'synapse.handlers.oidc': {
            level: 'DEBUG',
          },
        }
      },
      homeserver+: {     
        local mxDomain = 'dev.matrix.eclipsecontent.org',   
        oidc_providers_idp_icon_id::'55b53e24446e3dc22f8f964718bc192adbee0698',
        enable_registration: true,
        database+: {
          args+: {
            host: 'postgres-vm1',
          },
        },
        password_config: {
          enabled: true,
        },
        oidc_providers: [],
        modules: [
          {
            module: 'synapse.modules.synapse_user_control.UserControlModule',
            config: {
              creators: [
                '@sebastien.heurtematte:' + mxDomain,
                '@fred.gurr:' + mxDomain,
                '@ef_moderator_bot:' + mxDomain,       
                '@ef_sync_bot:' + mxDomain,                       
              ],
            },
          }
          // {
          //   module: 'synapse.modules.synapse_prevent_encrypt_room.SynapsePreventEncryptRoom',
          //   config: {
          //     allow_encryption_for_users: [
          //       '@sebastien.heurtematte:' + mxDomain,
          //       '@fred.gurr:' + mxDomain,
          //     ],
          //   },
          // },
        ],  

      },
    },    
    appservicePolicies+:{
      active:true,
      appservice+: {
        logLevel: "DEBUG",  
        skipMessage: "false"
      },
    },
    appserviceSlack+:{
      active:false,
    },
    matrixMediaRepo+: {
      active:true,
      mediarepo+: {
        database+: {
          host: 'postgres-vm1',
        },
      },
    },
    clamav+:{
      active:false,
    },
    pantalaimn+:{
      active:true,
    },
  },
}
