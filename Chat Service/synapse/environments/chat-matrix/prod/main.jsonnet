(import 'chat-matrix/main.libsonnet') +
(import '.secrets/secrets.jsonnet') +
{
  _config+:: {
    local config = self,
    environment: 'prod',
    synapse+: {
      replicas: 1,
      version: 'v1.87.0',
      resources+: {
        cpuRequest: '2000m',
        cpuLimit: '4000m',
        memoryRequest: '1000Mi',
        memoryLimit: '4000Mi',
      },
      logconfig+: {
        root+: {
          level: 'INFO',
        },
        loggers+: {
          synapse: {
            level: 'INFO',
          },
        },
      },
      homeserver+: {
        local mxDomain = 'matrix.eclipse.org',
        oidc_providers_idp_icon_id::'b57008339e0d330d439cf8d56e1d1ae0605be573',
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
          //       '@pawel.stankiewicz:'+ mxDomain,
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
          enabled: false,
        },
      },
    },
    appservicePolicies+:{
      active:true,
      appservice+: {
        logLevel: "INFO",
      },
    },
    appserviceSlack+:{
      active:true,
      appservice+: {
        logging: {
          console: "info",
        },
        matrix_admin_room: "!YPandPhjsngMranWeH:matrix.eclipse.org",
        bot_profile: {
          avatar_url: "mxc://matrix-media-repo.eclipsecontent.org/b57008339e0d330d439cf8d56e1d1ae0605be573"
        },
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
