(import 'chat-matrix/main.libsonnet') +
(import '.secrets/secrets.jsonnet') +
{
  _config+:: {
    local config = self,
    environment: 'staging',
    synapse+: {
      replicas: 1,
      version: 'v1.87.0',
      logconfig+: {
        root+: {
          level: 'DEBUG',
        },
        loggers+: {
          synapse: {
            level: 'INFO',
          },
        },
      },
      homeserver+: {
        local mxDomain = 'matrix-staging.eclipse.org',
        oidc_providers_idp_icon_id::'c427c460454985fc1ca04a25859907c3a03245a5',
        database+: {
          args+: {
            host: 'postgres-vm1',
          },
        }, 
        modules: [
          {
            module: 'synapse.modules.synapse_user_control.UserControlModule',
            config: {
              creators: [
                '@sebastien.heurtematte:' + mxDomain,
                '@fred.gurr:' + mxDomain,
                '@pawel.stankiewicz:'+ mxDomain,
                '@ef_moderator_bot:' + mxDomain,
                '@ef_sync_bot:' + mxDomain,
                '@ef_slack_bridge_bot:' + mxDomain,
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
        auto_join_rooms: [
          '#eclipsefdn:' + mxDomain,
          '#eclipsefdn.chat-support:' + mxDomain,
          '#eclipsefdn.general:' + mxDomain,
          '#eclipse-projects:' + mxDomain,
        ],
        password_config: {
          enabled: true,
        },
        allow_guest_access: false,
      },
    },
    appservicePolicies+:{
      active:true,
      appservice+: {
        logLevel: "DEBUG",
        skipMessage: "true"
      },
    },
    appserviceSlack+:{
      active:true,
      appservice+: {
        logging: {
          console: "debug",
        },
        //matrix_admin_room: "!becqmCHUKvDiueefgt:matrix-staging.eclipse.org"
        matrix_admin_room: "!BalazdlxkfLNdQikQn:matrix-staging.eclipse.org"
      },
    },
    matrixMediaRepo+: {
      mediarepo+: {     
        repo+: {
          logLevel: "INFO",  
        },
        database+: {
          host: 'postgres-vm1',
        },
      },
    },
    clamav+:{
      active:false,
    },
    synapseAdmin+: {
    },
    botMjolnir+: {
      mjolnir+: {
          logLevel: "INFO",  
      },
    },
    pantalaimon+: {      
      "pantalaimon.conf"+: {
        sections+: {
          Default+: {
              LogLevel: "Debug",
          }
        }
      }
    },
  },
}
