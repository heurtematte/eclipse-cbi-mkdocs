local util = import '../util.libsonnet';
local xtd = import "github.com/jsonnet-libs/xtd/main.libsonnet";
{
  local config = $._config,
  local secret = $._secret,
  
  _secret+:: {
    "matrix-media-repo"+:{
      "database_password": "XXXXXXXXXXXXXXXX"
    }
  },

  _config+:: {    
    local mxDomain = util.getDomain(config.matrixDomain, config.environment),
    matrixMediaRepo+:{
      mediarepo+:{
        "repo"+: {
          "bindAddress": "0.0.0.0",
          "port": config.matrixMediaRepo.containerPort,
          "logDirectory": "-",
          "logColors": true,
          "jsonLogs": false,
          "logLevel": "info",
          "trustAnyForwardedAddress": true,
          "useForwardedHost": false
        },
        "federation"+: {
          "backoffAt": 20
        },
        "database"+: {
          user:: if (config.environment == 'prod') then "matrix-media-repo_rw" else "matrix-media-repo-" + config.environment +"_rw",
          host:: "postgres-vm1",
          database::if (config.environment == 'prod') then "matrix-media-repo" else "matrix-media-repo-" + config.environment,
          sslmode::"disable",
          password::xtd.url.escapeString(secret["matrix-media-repo"].database_password),
          postgres: "postgres://" + self.user + ":" + self.password + "@" + self.host + "/" + self.database + "?sslmode=" + self.sslmode,
          pool: {
            maxConnections: 25,
            maxIdleConnections: 5
          }
        },
        "homeservers"+: [
          {
            "name": util.getDomain(config.matrixMediaRepoDomain, config.environment),
            "csApi": "http://synapse",
            "backoffAt": 10,
            "adminApiKind": "matrix"
          },
          {
            "name": mxDomain,
            "csApi": "http://synapse",
            "backoffAt": 10,
            "adminApiKind": "matrix"
          },
          {
            "name": "synapse-internal",
            "csApi": "http://synapse",
            "backoffAt": 10,
            "adminApiKind": "matrix"
          }
        ],
        "accessTokens"+: {
          "maxCacheTimeSeconds": 0,
          "useLocalAppserviceConfig": true,
          // "appservices"+: [
          //   {
          //     "id": "matrix"+calculateEnvironment+"",
          //     "asToken": "XXXXXXXXXX",
          //     "senderUserId": "@_example_bridge:matrix"+calculateEnvironment+".eclipse.org",
          //     "userNamespaces"+: [
          //       {
          //         "regex": "@_example_bridge_.+:matrix"+calculateEnvironment+".eclipse.org"
          //       }
          //     ]
          //   }
          // ]
        },
        "admins"+: [
          '@sebastien.heurtematte:' + mxDomain
        ],
        "sharedSecretAuth"+: {
          "enabled": false,
          "token": ""
        },
        "datastores"+: [
          {
            "type": "file",
            "enabled": true,
            "forKinds": [
              "thumbnails",
              "remote_media",
              "local_media",
              "archives"
            ],
            "opts": {
              "path": "/var/matrix/media"
            }
          },
          {
            "type": "s3",
            "enabled": false,
            "forKinds": [
              "thumbnails",
              "remote_media",
              "local_media",
              "archives"
            ],
            "opts": {
              "tempPath": "/tmp/mediarepo_s3_upload",
              "endpoint": "sfo2.digitaloceanspaces.com",
              "accessKeyId": "",
              "accessSecret": "",
              "ssl": true,
              "bucketName": "your-media-bucket"
            }
          },
          {
            "type": "ipfs",
            "enabled": false,
            "forKinds": [
              "local_media"
            ],
            "opts": {}
          }
        ],
        "archiving"+: {
          "enabled": true,
          "selfService": false,
          "targetBytesPerPart": 209715200
        },
        "uploads"+: {
          "maxBytes": 104857600,
          "minBytes": 100,
          "quotas": {
            "enabled": false,
            "users": [
              {
                "glob": "@*:*",
                "maxBytes": 1000000000
              }
            ]
          }
        },
        "downloads"+: {
          "maxBytes": 104857600,
          "numWorkers": 10,
          "failureCacheMinutes": 5,
          "expireAfterDays": 0,
          "defaultRangeChunkSizeBytes": 10485760
        },
        "urlPreviews"+: {
          "enabled": true,
          "maxPageSizeBytes": 10485760,
          "previewUnsafeCertificates": false,
          "numWords": 50,
          "maxLength": 200,
          "numTitleWords": 30,
          "maxTitleLength": 150,
          "filePreviewTypes": [
            "image/*"
          ],
          "numWorkers": 10,
          "disallowedNetworks": [
            "127.0.0.1/8",
            "10.0.0.0/8",
            "172.16.0.0/12",
            "192.168.0.0/16",
            "100.64.0.0/10",
            "169.254.0.0/16",
            "::1/128",
            "fe80::/64",
            "fc00::/7"
          ],
          "allowedNetworks": [
            "0.0.0.0/0"
          ],
          "expireAfterDays": 0,
          "defaultLanguage": "en-US,en",
          "userAgent": "matrix-media-repo",
          "oEmbed": false
        },
        "thumbnails"+: {
          "maxSourceBytes": 10485760,
          "maxPixels": 32000000,
          "numWorkers": 100,
          "sizes": [
            {
              "width": 32,
              "height": 32
            },
            {
              "width": 96,
              "height": 96
            },
            {
              "width": 320,
              "height": 240
            },
            {
              "width": 640,
              "height": 480
            },
            {
              "width": 768,
              "height": 240
            },
            {
              "width": 800,
              "height": 600
            }
          ],
          "dynamicSizing": false,
          "types": [
            "image/jpeg",
            "image/jpg",
            "image/png",
            "image/apng",
            "image/gif",
            "image/heif",
            "image/svg+xml",
            "image/webp",
            "audio/mpeg",
            "audio/ogg",
            "audio/wav",
            "audio/flac"
          ],
          "allowAnimated": true,
          "defaultAnimated": false,
          "maxAnimateSizeBytes": 10485760,
          "stillFrame": 0.5,
          "expireAfterDays": 0
        },
        "rateLimit"+: {
          "enabled": true,
          "requestsPerSecond": 1,
          "burst": 10
        },
        "identicons"+: {
          "enabled": true
        },
        "quarantine"+: {
          "replaceThumbnails": true,
          "replaceDownloads": false,
          "allowLocalAdmins": true
        },
        "timeouts"+: {
          "urlPreviewTimeoutSeconds": 10,
          "federationTimeoutSeconds": 120,
          "clientServerTimeoutSeconds": 30
        },
        "metrics"+: {
          "enabled": true,
          "bindAddress": "0.0.0.0",
          "port": 9000
        },
        "featureSupport"+: {
          "MSC3827"+: {
            "enabled": true
          },
          "MSC2448"+: {
            "enabled": false,
            "maxWidth": 1024,
            "maxHeight": 1024,
            "thumbWidth": 64,
            "thumbHeight": 64,
            "xComponents": 4,
            "yComponents": 3,
            "punch": 1
          },
          "IPFS"+: {
            "enabled": false,
            "builtInDaemon": {
              "enabled": true,
              "repoPath": "./ipfs"
            }
          }
        },
        "redis"+: {
          "enabled": false,
          "databaseNumber": 0,
          "shards": [
            {
              "name": "server1",
              "addr": ":7000"
            },
            {
              "name": "server2",
              "addr": ":7001"
            },
            {
              "name": "server3",
              "addr": ":7002"
            }
          ]
        },
        "sentry"+: {
          "enabled": false,
          "dsn": "https://examplePublicKey@ingest.sentry.io/0",
          "environment": "",
          "debug": false
        }
      }
    }
  }
}