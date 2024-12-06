<!--
SPDX-FileCopyrightText: 2023 eclipse foundation
SPDX-License-Identifier: EPL-2.0
-->

# Chat Service Sync 

This project allow to configure matrix as code (room/space, permission), and to sync permission with Eclipse Foundation profile like project lead.

- [Chat Service Sync](#chat-service-sync)
  - [Environment configuration](#environment-configuration)
  - [Project file configuration](#project-file-configuration)
    - [Default](#default)
    - [Project room/space definition](#project-roomspace-definition)
- [Installation](#installation)
  - [Create sync bot](#create-sync-bot)
  - [launch](#launch)
- [Development](#development)

## Environment configuration

Configuration file: `./config/default.js`

| Configuration Parameter | Description | Default Value | Environment Variable |
| --- | --- | --- | --- |
| `logLevel` | The log level for the service. | `"DEBUG"` | `SYNC_LOG_LEVEL` |
| `dry` | Dry mode execution | `true` | `SYNC_DRY` |
| `projectConfigFile` | Locate configuration file. | `__dirname + `/project.yaml`` | `SYNC_PROJECT_CONFIG_FILE` |
| `matrixAPI` | Object configuration for matrix API. (see definition below) |  |  |
| `eclipseAPI` | Object configuration for eclipse API. (see definition below) |  |  |

* `matrixAPI` object configuration 

| Configuration Parameter | Description | Default Value | Environment Variable |
| --- | --- | --- | --- |
| `baseUrl` | Base url of the homeserver. | `https://matrix-local.eclipse.org` | `SYNC_PERMS_HOMESERVER_URL` |
| `accessToken` | Acces token to homeserver API. | `XXXXXXXXXXXXX` | `SYNC_PERMS_HOMESERVER_TOKEN` |
| `matrixDomain` | Matrix domain, can be different from baseUrl. | `matrix-local.eclipse.org` | `SYNC_PERMS_HOMESERVER_DOMAIN` |


* `eclipseAPI` object configuration 


| Configuration Parameter | Description | Default Value | Environment Variable |
| --- | --- | --- | --- |
| `userAPIBaseUrl` | Base url of the homeserver. | `https://matrix-local.eclipse.org` | `SYNC_PERMS_HOMESERVER_URL` |
| `projectAPIBaseUrl` | Acces token to homeserver API. | `XXXXXXXXXXXXX` | `SYNC_PERMS_HOMESERVER_TOKEN` |
| `oauth` | Matrix domain, can be different from baseUrl. | `matrix-local.eclipse.org` | `SYNC_PERMS_HOMESERVER_DOMAIN` |
| `additionnalOauth` | Matrix domain, can be different from baseUrl. | `matrix-local.eclipse.org` | `SYNC_PERMS_HOMESERVER_DOMAIN` |

* `oauth` object configuration 

Configuration object from library: [simple-oauth2](https://github.com/lelylan/simple-oauth2)

| Configuration Parameter | Description | Default Value | Environment Variable |
| --- | --- | --- | --- |
| `client.id` | Client id | `XXXXXXXXXXXXXX` | `SYNC_ECLIPSE_API_OAUTH_CLIENT_ID` |
| `client.secret` | Client secret. | `XXXXXXXXXXXXXX` | `SYNC_ECLIPSE_API_OAUTH_SECRET` |
| `auth.tokenHost` | Oauth domain | `https://accounts.eclipse.org` | `SYNC_ECLIPSE_API_OAUTH_AUTH_TOKEN_HOST` |
| `auth.tokenPath` | Oauth token path. | `/oauth2/token` | `SYNC_ECLIPSE_API_OAUTH_AUTH_TOKEN_PATH` |

* `additionnalOauth` object configuration 

Extrat oauth options: 

| Configuration Parameter | Description | Default Value | Environment Variable |
| --- | --- | --- | --- |
| `timeout` | Request timeout | `3600` | `SYNC_ECLIPSE_API_ADDITIONNALOAUTH_TIMEOUT` |
| `scope` | Oauth scope for viewing profile. | `eclipsefdn_view_all_profiles` | `SYNC_ECLIPSE_API_ADDITIONNALOAUTH_SCOPE` |

Default configuration file: 

```javascript
logLevel: process.env.SYNC_LOG_LEVEL || "INFO",
    dry: process.env.SYNC_DRY || true,
    projectConfigFile: process.env.SYNC_PROJECT_CONFIG_FILE || __dirname + `/project.yaml`,
    matrixAPI: { 
        baseUrl: process.env.SYNC_PERMS_HOMESERVER_URL || "https://matrix-local.eclipse.org", 
        accessToken: process.env.SYNC_PERMS_HOMESERVER_TOKEN || "XXXXXXXXXXXXX",
        matrixDomain: process.env.SYNC_PERMS_HOMESERVER_DOMAIN || "matrix-local.eclipse.org", 
    },
    eclipseAPI: {
        userAPIBaseUrl: process.env.SYNC_ECLIPSE_USER_API_BASE_URL || 'https://api.eclipse.org',
        projectAPIBaseUrl: process.env.SYNC_ECLIPSE_PROJECT_API_BASE_URL || 'https://projects.eclipse.org',
        oauth: {
            client: {
                id: process.env.SYNC_ECLIPSE_API_OAUTH_CLIENT_ID || 'XXXXXXXXXXXXX',
                secret: process.env.SYNC_ECLIPSE_API_OAUTH_SECRET || 'XXXXXXXXXXXXXX',
            },
            auth: {
                tokenHost: process.env.SYNC_ECLIPSE_API_OAUTH_AUTH_TOKEN_HOST || 'https://accounts.eclipse.org',
                tokenPath: process.env.SYNC_ECLIPSE_API_OAUTH_AUTH_TOKEN_PATH || '/oauth2/token',
            }
        },
        additionnalOauth: {
            timeout: parseInt(process.env.SYNC_ECLIPSE_API_ADDITIONNALOAUTH_TIMEOUT) || 3600,
            scope: process.env.SYNC_ECLIPSE_API_ADDITIONNALOAUTH_SCOPE ||  'eclipsefdn_view_all_profiles'
        },
    }
```

## Project file configuration

### Default


| Configuration Parameter | Description | 
| --- | --- | 
| `users` | List of default users with permission (optionnal) apply to all room/space | 
| `defaultProjectSpace` | Define default project space for all Room. Just de reference for later use in other yaml definition |
| `userPowerLevel` | Default powerlevel for user if not define: default format `@ef_moderator_bot': 60`, but `@ef_moderator_bot` will result in `@ef_moderator_bot': 50` with default `userPowerLevel`  |
| `roomPowerLevel` | Default powerlevel for room/space, call state event `/rooms/$roomId/state/m.room.power_levels`, see [mroompower_levels](https://spec.matrix.org/latest/client-server-api/#mroompower_levels) for specification |
| `roomVisibility` | `public`, `private`. Define at room creation, see [createRoom API](https://spec.matrix.org/latest/client-server-api/#post_matrixclientv3createroom) |
| `roomPreset` | `private_chat`, `trusted_private_chat`, `public_chat`. Define at room creation, see [createRoom API](https://spec.matrix.org/latest/client-server-api/#post_matrixclientv3createroom) |


Example:

```yaml
default:
  users: &defaultUsers
    - '@sebastien.heurtematte': 100
    - '@ef_sync_bot': 100
    - '@ef_moderator_bot': 60
  defaultProjectSpace: '#eclipse-projects'
  userPowerLevel: 50
  roomPowerLevel:
    ban: 50
    events:
      m.reaction: 0
      m.room.avatar: 55
      m.room.canonical_alias: 55
      m.room.encryption: 100
      m.room.history_visibility: 100
      m.room.name: 55
      m.room.pinned_events: 50
      m.room.power_levels: 100
      m.room.redaction: 0
      m.room.server_acl: 60
      m.room.tombstone: 100
      m.room.topic: 50
      m.space.child: 55
      org.matrix.msc3401.call: 50
      org.matrix.msc3401.call.member: 50
    events_default: 0
    historical: 100
    invite: 50
    kick: 50
    redact: 50
    state_default: 50
    users_default: 0
  roomVisibility: "public"
  roomPreset: "public_chat"
```


### Project room/space definition


| Configuration Parameter | Description | Example |
| --- | --- | --- | 
| `{project_id}` | Eclipse Project_id as define in eclipse project website: https://projects.eclipse.org | `ee4j.rest` |
| `projectLead` | Sync moderator permission with project lead. Only if project_id is valid  | `true` |
| `rooms` | Defining a list of room/space.  |  |


Room/space options: 

| Configuration Parameter | Description | Optionnal | default value | Example |
| --- | --- | --- | --- | --- |
| `alias` | Eclipse Project_id as define in eclipse project website: https://projects.eclipse.org | false | | `ee4j.rest` |
| `extraAlias` | string or array that allows to add extra alias for room  | true | | `ee4j-general.rest` |
| `name` | Set room name  | false | | `Jakarta RESTful Web Services™` |
| `type` | Define if it's a space or a room. Room by default.  | true | `room`, `space`|
| `topic` | Define topic for this room  | true | | |
| `visibility` | Define visibility for this room/space | true | `public` | `public`, `private` |
| `preset` | Define preset for this room/space | true | `public_chat` |  `private_chat`, `trusted_private_chat`, `public_chat` |
| `powerLevel` | Define specific powerLevel for this room/space | true | | |
| `projectLead` | Sync extra project lead permission. Only if project_id is valid | true | `true` | |
| `projectId` | Sync extra project lead permission with a valid project_id | true | | |
| `users` | Define a list of extra users for moderation | true | | |
| `parent` | Define parent space. | true | | `#eclipse-projects` |
| `forceUpdate` | Allow the script to override any change occuring by the UI. Only fields topic for the moment. | true | `false` | `true` |
| `encryption` | Allow to encrypt room. | true | `false` | `true` |

Example:


```yaml
projects:
  - eclipsefdn:
      projectLead: false
      rooms:
        - alias: '#eclipsefdn'
          name: 'Eclipse Foundation'
          type: space
        - alias: '#eclipsefdn.it'
          type: room
          name: 'IT'
          parent: '#eclipsefdn'
```


# Installation

## Create sync bot

IMPORTANT: Activate for a short period registration in matrix.

1. create sync user: `@ef_sync_bot:matrix.eclipse.org`

Get password from pass: /IT/services/chat-service/chat-service-sync/{env}/password

```shell
MATRIX_URL="https://matrix.eclipse.org"
ACCESS_TOKEN="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

curl -k -s -X PUT \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -d '{"displayname": "Eclipse Foundation Sync Bot", "password": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", "admin": true}' \
    "${MATRIX_URL}/_synapse/admin/v2/users/@ef_sync_bot:${MATRIX_URL##*://}"
```

2. Get access_token


```shell
MATRIX_URL="https://matrix.eclipse.org"
ACCESS_TOKEN="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
curl -k -s -X POST \
    -d '{"type":"m.login.password", "user":"ef_sync_bot", "password":"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"}' \
    "${MATRIX_URL}/_matrix/client/r0/login"
```

3. Accept consent policy: Need to connect to the web interface with user `ef_sync_bot` or calculate consent url.

Param openssl hmac is `form_secret`property in `homeserver.yaml`: `pass /IT/services/chat-service/synapse/prod/form_secret`

```shell
echo -n 'ef_sync_bot' | openssl sha256 -hmac 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
```

```
https://matrix.eclipse.org/_matrix/consent?u=ef_sync_bot&h=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

4. Get Device

```shell
MATRIX_URL="https://matrix.eclipse.org"
ACCESS_TOKEN="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

curl -s -X GET \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    "${MATRIX_URL}/_matrix/client/v3/devices"
```

and set deviceId in configuration:

```json
matrixAPI: { 
        deviceId: "XXXXXXXXXXX", 
    },
```

5. Set rate limit:

```sql
insert into ratelimit_override values ('@ef_sync_bot:matrix.eclipse.org', 0, 0);
```

or via curl: 

```shell
MATRIX_URL="https://matrix.eclipse.org"
ACCESS_TOKEN="YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY"


curl -k -s -X POST \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -d '{"messages_per_second": 0, "burst_count": 0}' \
    "${MATRIX_URL}/_synapse/admin/v1/users/@ef_sync_bot:${MATRIX_URL##*://}/override_ratelimit"
```

6. Add bot to existing room

If rooms already exist, bot must be add manually first.

## launch

```shell
npm install 
npm run build
npm run start
```


# Development

## Dev file environment

Create a `dev.js` file in `./config`, and overwrite all configuration from `default.json`.


```shell
npm install 
npm run build
npm run start-dev
```