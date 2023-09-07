local util = import '../util.libsonnet';
{

  local secret = $._secret,
  _secret+:: {
    synapse+: {
      database_password: 'XXXXXXXXXXXXXXXX',
      form_secret: 'XXXXXXXXXXXXXXXX',
      macaroon_secret_key: 'XXXXXXXXXXXXXXXX',
      oidc_providers_oauth2_eclipse_secret: 'XXXXXXXXXXXXXXXX',
      registration_shared_secret: 'XXXXXXXXXXXXXXXX',
      signing: 'XXXXXXXXXXXXXXXX',
    },
  },
  _config+:: {
    local config = self,
    local mxDomain = util.getDomain(config.matrixDomain, config.environment),
    local clientDomain = util.getDomain(config.chatDomain, config.environment),
    local mediaDomain = util.getDomain(config.matrixMediaRepoDomain, config.environment),

    synapse+: {
      homeserver+: {
        local homeserver = self,
        modules+: [
          {
            module: 'synapse.modules.synapse_user_control.UserControlModule',
            config: {
              creators: [
                '@sebastien.heurtematte:' + mxDomain,
              ],
            },
          }
          // {
          //   module: 'synapse.modules.synapse_prevent_encrypt_room.SynapsePreventEncryptRoom',
          //   config: {
          //     allow_encryption_for_users: [
          //       '@sebastien.heurtematte:' + mxDomain,
          //     ],
          //   },
          // },
        ],
        server_name: mxDomain,
        pid_file: '/synapse/data/homeserver.pid',
        web_client_location: 'https://' + clientDomain + '/',
        serve_server_wellknown: true,
        presence: {
          enabled: true,
        },
        allow_public_rooms_over_federation: true,
        listeners: [
          {
            port: 8008,
            tls: false,
            type: 'http',
            x_forwarded: true,
            resources: [
              {
                names: [
                  'client',
                  'federation',
                  'consent',
                ],
                compress: false,
              },
            ],
          },
          //slack endpoint
          {
            port: 8009,
            tls: false,
            type: 'http',
            x_forwarded: true,
            bind_addresses: ['::1', '127.0.0.1'],
            resources: [
              {
                names: [
                  'client',
                  'federation',
                  'consent',
                ],
                compress: false,
              },
            ],
          },
          {
            port: 9008,
            tls: false,
            type: 'metrics',
          },
        ],
        // manhole_settings: null,
        admin_contact: 'mailto:sebastien.heurtematte@eclipse-foundation.org',
        limit_remote_rooms: {
          enabled: true,
          complexity: 0.5,
          complexity_error: "This room is too complex to be join on the homeserver. Please contact an Administrator.",
          admins_can_join: true,
        },
        // max_avatar_size: '10M', # deactivate for matrix-media-repo
        // templates: null,
        // retention: null,
        // caches: {
        //   per_cache_factors: null,
        // },
        database: {
          name: 'psycopg2',
          txn_limit: 10000,
          args: {
            user: if (config.environment == 'prod') then 'synapse_rw' else 'synapse-' + config.environment + '_rw',
            password: secret.synapse.database_password,
            database: if (config.environment == 'prod') then 'synapse' else 'synapse-' + config.environment + '',
            host: 'postgres-vm1',
            port: 5432,
            cp_min: 5,
            cp_max: 10,
          },
        },
        log_config: '/synapse/log/' + mxDomain + '.log.config.yaml',
        media_store_path: '/synapse/data/media_store',
        url_preview_enabled: true,
        url_preview_ip_range_blacklist: [],
        url_preview_accept_language: [
          '*',
        ],
        // oembed: null,
        enable_registration: false,
        enable_registration_without_verification: false,
        registrations_require_3pid: [
          'email',
        ],
        registration_shared_secret: secret.synapse.registration_shared_secret,
        allow_guest_access: true,
        // account_threepid_delegates: null,
        auto_join_rooms: [
          '#eclipsefdn:' + mxDomain,
          '#eclipsefdn.chat-support:' + mxDomain,
          '#eclipsefdn.general:' + mxDomain,
        ],
        enable_metrics: true,
        // metrics_flags: null,
        report_stats: true,
        report_stats_endpoint: 'http://localhost:' + config.stats.containerPort,
        // room_prejoin_state: null,
        app_service_config_files : ["/synapse/appservice/appservice-policies.yaml", "/synapse/appserviceslack/appservice-slack.yaml"],
        macaroon_secret_key: secret.synapse.macaroon_secret_key,
        form_secret: secret.synapse.form_secret,
        signing_key_path: '/synapse/keys/' + mxDomain + '.signing.key',
        // old_signing_keys: null,
        trusted_key_servers: [
          {
            server_name: 'matrix.org',
          },
        ],
        suppress_key_server_warning: true,
        // saml2_config: {
        //   sp_config: null,
        //   user_mapping_provider: null,
        //   config: null,
        // },
        oidc_providers_oauth2_eclipse_secret:: secret.synapse.oidc_providers_oauth2_eclipse_secret,
        oidc_providers_idp_icon_id:: '55b53e24446e3dc22f8f964718bc192adbee0698',
        oidc_providers: [
          {
            idp_id: 'oauth2_eclipse',
            idp_name: 'Eclipse Foundation Account',
            idp_icon: 'mxc://' + mediaDomain + '/' + homeserver.oidc_providers_idp_icon_id,
            allow_existing_users: true,            
            discover: false,
            jwks_verify: false,
            issuer: 'https://accounts.eclipse.org',
            client_id: if (config.environment == 'prod') then 'matrix_eclipse_org' else 'matrix_' + config.environment + '_eclipse_org',
            client_secret: homeserver.oidc_providers_oauth2_eclipse_secret,
            client_auth_method: 'client_secret_post',
            scopes: [
              'openid',
              'profile',
              'email',
            ],
            authorization_endpoint: 'https://accounts.eclipse.org/oauth2/authorize',
            token_endpoint: 'https://accounts.eclipse.org/oauth2/token',
            userinfo_endpoint: 'https://accounts.eclipse.org/oauth2/UserInfo',
            user_profile_method: 'userinfo_endpoint',
            user_mapping_provider: {
              config: {
                subject_claim: 'sub',
                localpart_template: '{{ user.email|localpart_from_email }}',
                display_name_template: '{{ user.full_name }}',
                email_template: '{{ user.email }}',
                confirm_localpart: true,
              },
            },
          },
        ],
        // cas_config: null,
        // sso: null,
        password_config: {
          enabled: false,
          policy: null,
        },
        // ui_auth: null,
        email: {
          smtp_host: 'mail.eclipse.org',
          enable_tls: false,
          notif_from: '%(app)s <no-reply@eclipse.org>',
          app_name: 'Chat Service at Eclipse',
          enable_notifs: true,
          notif_for_new_users: true,
          client_base_url: 'https://' + clientDomain,
          invite_client_location: 'https://' + clientDomain,
        },
        // push: null,
        user_directory: {
          enabled: true,
          search_all_users: true,
          prefer_local_users: true
        },
        user_consent: {
          template_dir: '/synapse/privacy_policy_templates',
          version: '1.0',
          server_notice_content: {
            msgtype: 'm.text',
            body: 'To continue using Chat Service at Eclipse Foundation you must review and agree to the terms and conditions at %(consent_uri)s',
          },
          send_server_notice_to_guests: true,
          block_events_error: 'To continue using Chat Service at Eclipse Foundation you must review and agree to the terms and conditions at %(consent_uri)s',
          require_at_registration: true,
          policy_name: 'Eclipse Foundation Privacy Policy',
        },
        // stats: null,
        server_notices: {
          system_mxid_localpart: 'eclipsewebmaster',
          system_mxid_display_name: 'Eclipse Webmaster Notices',
          system_mxid_avatar_url: 'mxc://'+mediaDomain+'/oumMVlgDnLYFaPVkExemNVVZ',
          room_name: 'Eclipse Webmaster Notices',
        },
        // opentracing: null,
        // redis: null,
        // background_updates: null,
      },
    },
  },
}
