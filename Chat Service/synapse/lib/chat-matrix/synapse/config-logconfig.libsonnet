{
  _config+:: {
    synapse+: {
      logconfig+: {
        version: 1,
        formatters+: {
          precise+: {
            format: '%(asctime)s - %(levelname)s - %(name)s - %(lineno)d - %(request)s - %(message)s',
          },
        },
        handlers+: {
          console+: {
            class: 'logging.StreamHandler',
            formatter: 'precise',
          }
        },
        root+: {
          level: 'INFO',
          handlers+: [
            'console',
          ],
        },
        loggers+: {
          synapse: {
            level: 'INFO',
          },
          // 'synapse.access.http': {
          //   level: 'ERROR',
          // },
          // 'synapse.handlers': {
          //   level: 'ERROR',
          // },
          // 'synapse.storage.SQL': {
          //   level: 'ERROR',
          // },
          // 'synapse.federation.sender': {
          //   level: 'ERROR',
          // },
          // 'synapse.modules': {
          //   level: 'ERROR',
          // },
          // 'synapse.handlers.profile': {
          //   level: 'ERROR',
          // },
          // 'synapse.handlers.register': {
          //   level: 'ERROR',
          // },
          // 'synapse.handlers.sso': {
          //   level: 'ERROR',
          // },
          // 'synapse.handlers.oidc': {
          //   level: 'ERROR',
          // },
        },
      },

    },
  },
}
