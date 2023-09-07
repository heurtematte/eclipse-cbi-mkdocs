local util = import '../util.libsonnet';
local xtd = import "github.com/jsonnet-libs/xtd/main.libsonnet";

{
  local secret = $._secret,
  _secret+:: {
    appservice+: {
      asToken: "XXXXXXXXXXXXXXXX",
      hsToken: "YYYYYYYYYYYYYYYY",
    },
    "matrix-appservice-slack"+: {
      database_password: "XXXXXXXXXXXXXXXX"
    }
  },
  _config+:: {    
    local config = self,
    local mxDomain = util.getDomain(config.matrixDomain, config.environment),
    local matrixMediaRepoDomain = util.getDomain(config.matrixMediaRepoDomain, config.environment),
    local matrixDomain = util.getDomain(config.matrixDomain, config.environment),
    
    appserviceSlack+: {
      appservice+: {
        homeserver: {
          server_name: mxDomain,
          //url: "http://matrix-staging.eclipse.org",
          url: "http://synapse-nginx",
          //url: "https://" + matrixDomain,
          //url: "http://localhost:8009",
          media_url: "https://" + matrixMediaRepoDomain,
          //media_url: "http://matrix-media-repo",
          max_upload_size: 104857600,
          appservice_port: 5858,
          appservice_host: "::"
        },
        username_prefix: "slack_",
        rmau_limit: 1000,
        db: {
          engine: "postgres",
          user:: if (config.environment == 'prod') then "matrix-appservice-slack_rw" else "matrix-appservice-slack-" + config.environment +"_rw",
          host:: "postgres-vm1",
          database::if (config.environment == 'prod') then "matrix-appservice-slack" else "matrix-appservice-slack-" + config.environment,
          sslmode::"disable",
          password::xtd.url.escapeString(secret["matrix-appservice-slack"].database_password),
          connectionString: "postgres://" + self.user + ":" + self.password + "@" + self.host + "/" + self.database + "?sslmode=" + self.sslmode,
        },
        matrix_admin_room: "!aBcDeF:matrix.org",
        // tls: {
        //   key_file: "/path/to/tls.key",
        //   crt_file: "/path/to/tls.crt"
        // },
        rtm: {
          enable: true,
          log_level: "info"
        },
        // slack_hook_port: 9898,
        // slack_proxy: "https://proxy.server.here:3128",
        // inbound_uri_prefix: "https://my.server.here:9898/",
        oauth2: {
          client_id: "xxxxxxxx",
          client_secret: "xxxxxxxxxxxx",
          scope: "users:read,channels:history,channels:read,files:write:user,chat:write:bot,users:read,bot",
          redirect_prefix: "https://slack.com/oauth/v2/authorize?scope="+self.scope+"&client_id=" + self.client_id
        },
        logging: {
          console: "debug",
          // "files": {
          //   "./debug.log": "info",
          //   "./error.log": "error"
          // }
        },
        enable_metrics: true,
        // team_sync: {
        //   "T0123ABCDEF": {
        //     "channels": {
        //       "enabled": true,
        //       "allow_private": true,
        //       "allow_public": true,
        //       "blacklist": [
        //         "CVCCPEY9X",
        //         "C0108F9K37X"
        //       ],
        //       "whitelist": [],
        //       "alias_prefix": "slack_",
        //       "hint_channel_admins": true
        //     },
        //     "users": {
        //       "enabled": true
        //     }
        //   },
        //   all: {
        //     channels: {
        //       enabled: false,
        //       whitelist: [
        //         "CVCCPEY9X"
        //       ],
        //       blacklist: [],
        //       alias_prefix: "slack_"
        //     },
        //     users: {
        //       enabled: false
        //     }
        //   }
        // },
        provisioning: {
          enabled: true,
          widgets: true,
          require_public_room: true,
          allow_private_channels: true,
          // limits: {
          //   room_count: 20,
          //   team_count: 1
          // },
          // channel_adl: {
          //   allow: [
          //     "CCZ41UJV7",
          //     "#open.*"
          //   ],
          //   deny: [
          //     "CRBCPA771",
          //     "#secret.*"
          //   ]
          // }
        },
        puppeting: {
          enabled: false,
          onboard_users: false,
          direct_messages: {
            allow: {
              // slack: [
              //   "U0156TG3W48"
              // ],
              matrix: [
                "@.*:" + mxDomain
              ]
            },
            // deny: {
            //   slack: [
            //     "U0156TG3W48"
            //   ],
            //   matrix: [
            //     "@badactor:badhost",
            //     "@.*:badhost"
            //   ]
            // }
          }
        },
        bot_profile: {
          displayname: "Eclipse Foundation Slack Bridge Bot",
          avatar_url: "mxc://half-shot.uk/ea64c71ee946ca2f61379abefe2c7d977d276fbb"
        },
        encryption: {
          enabled: false,
          pantalaimon_url: "http://pantalaimon"
        }
      },
    }
  },

}
