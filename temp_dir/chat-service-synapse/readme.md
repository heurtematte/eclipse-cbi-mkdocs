<!--
SPDX-FileCopyrightText: 2023 eclipse foundation
SPDX-License-Identifier: EPL-2.0
-->

# Eclipse Foundation - Synapse Matrix Server Implementation

[[_TOC_]]

# Architecture

Architecture diagram is create with [structurizr](https://structurizr.com), dsl is available [here](./docs/structurizr.dsl).

```mermaid
graph LR
  linkStyle default fill:#ffffff

  subgraph diagram [Chat Service - Containers]
    style diagram fill:#ffffff,stroke:#ffffff

    1["<div style='font-weight: bold'>Eclipse Account User</div><div style='font-size: 70%; margin-top: 0px'>[Person]</div><div style='font-size: 80%; margin-top:10px'>An Eclipse Foundation account<br />user.</div>"]
    style 1 fill:#08427b,stroke:#052e56,color:#ffffff
    2["<div style='font-weight: bold'>User Federated</div><div style='font-size: 70%; margin-top: 0px'>[Person]</div><div style='font-size: 80%; margin-top:10px'>An Matrix federated account<br />user.</div>"]
    style 2 fill:#08427b,stroke:#052e56,color:#ffffff

    subgraph 4 [Chat Service]
      style 4 fill:#ffffff,stroke:#0b4884,color:#0b4884

      10["<div style='font-weight: bold'>Synapse Database</div><div style='font-size: 70%; margin-top: 0px'>[Container]</div>"]
      style 10 fill:#dddddd,stroke:#9a9a9a,color:#000000
      12["<div style='font-weight: bold'>Elementweb</div><div style='font-size: 70%; margin-top: 0px'>[Container]</div><div style='font-size: 80%; margin-top:10px'>chat.eclipse.org</div>"]
      style 12 fill:#dddddd,stroke:#9a9a9a,color:#000000
      14["<div style='font-weight: bold'>Matrix-Media-Repo</div><div style='font-size: 70%; margin-top: 0px'>[Container]</div><div style='font-size: 80%; margin-top:10px'>matrix-media-repo.eclipsecontent.org</div>"]
      style 14 fill:#dddddd,stroke:#9a9a9a,color:#000000
      18["<div style='font-weight: bold'>Matrix-Media-Repo Database</div><div style='font-size: 70%; margin-top: 0px'>[Container]</div>"]
      style 18 fill:#dddddd,stroke:#9a9a9a,color:#000000
      20["<div style='font-weight: bold'>appservice-policies</div><div style='font-size: 70%; margin-top: 0px'>[Container]</div><div style='font-size: 80%; margin-top:10px'>matrix-media-repo.eclipsecontent.org</div>"]
      style 20 fill:#dddddd,stroke:#9a9a9a,color:#000000
      23["<div style='font-weight: bold'>bot-mjolnir</div><div style='font-size: 70%; margin-top: 0px'>[Container]</div><div style='font-size: 80%; margin-top:10px'>Moderation bot</div>"]
      style 23 fill:#dddddd,stroke:#9a9a9a,color:#000000
      25["<div style='font-weight: bold'>pantalaimon</div><div style='font-size: 70%; margin-top: 0px'>[Container]</div><div style='font-size: 80%; margin-top:10px'>Proxy for encrypt rooms</div>"]
      style 25 fill:#dddddd,stroke:#9a9a9a,color:#000000
      5["<div style='font-weight: bold'>Synapse</div><div style='font-size: 70%; margin-top: 0px'>[Container]</div><div style='font-size: 80%; margin-top:10px'>matrix.eclipse.org</div>"]
      style 5 fill:#dddddd,stroke:#9a9a9a,color:#000000
    end

    5-. "<div>Reads from and writes to</div><div style='font-size: 70%'></div>" .->10
    1-. "<div>Uses</div><div style='font-size: 70%'></div>" .->12
    5-. "<div>Uses</div><div style='font-size: 70%'></div>" .->14
    1-. "<div>Uses</div><div style='font-size: 70%'></div>" .->14
    2-. "<div>Uses</div><div style='font-size: 70%'></div>" .->14
    14-. "<div>Reads from and writes to</div><div style='font-size: 70%'></div>" .->18
    5-. "<div>Uses</div><div style='font-size: 70%'></div>" .->20
    20-. "<div>Uses</div><div style='font-size: 70%'></div>" .->5
    23-. "<div>Uses</div><div style='font-size: 70%'></div>" .->5
    23-. "<div>Uses</div><div style='font-size: 70%'></div>" .->25
    25-. "<div>Uses</div><div style='font-size: 70%'></div>" .->5
    1-. "<div>Uses</div><div style='font-size: 70%'></div>" .->5
    2-. "<div>Uses</div><div style='font-size: 70%'></div>" .->5
  end

```

# Getting started locally 

## prerequisite

Set local domain name in `/etc/hosts`:

```shell
127.0.0.1       matrix-local.eclipse.org chat-local.eclipse.org matrix-media-repo-local.eclipse.org synapse-admin-local.eclipse.org 
127.0.0.1       matrix-federated.eclipse.org chat-federated.eclipse.org matrix-media-repo-federated.eclipse.org synapse-admin-federated.eclipse.org
```

## Local start

```shell 
docker-compose build
docker-compose up -d
```

Do the same on `ef-element-web` project and start docker-compose up.

Browser access: `https://chat-local.eclipse.org:8443`


![matrix dev architecture](./docs/img/docker-compose.png)

## Local federated start

```shell 
docker-compose -f docker-compose-federated.yaml build
docker-compose -f docker-compose-federated.yaml up -d
```
Matrix access: `https://matrix-local.eclipse.org`
Matrix access: `https://matrix-federated.eclipse.org`

Do the same on `ef-element-web` project and start docker-compose up.

Browser access: `https://chat-local.eclipse.org:8443`
Browser access: `https://chat-federated.eclipse.org:8443`


![matrix dev federated architecture](./docs/img/docker-compose-federated.png)

# Installation and Configuration in kubernetes cluster

## Kubernetes architecture

![k8s matrix synapse architecture](./docs/img/k8s-architecture.png)

## Install modules

Install `jsonnet-bundler`: https://github.com/jsonnet-bundler/jsonnet-bundler

```shell
jb install
```

## New Environment

```shell
tk env add environments/chat-matrix/{env} --namespace=chat-matrix-{env}
```

Add this property in `spec.json`:

```json
{
  ...
"apiServer": "https://my_cluster",
"injectLabels": true
 ...
}
```

`main.jsonnet` template: 

```json
(import 'chat-matrix/main.libsonnet') +
(import '.secrets/secrets.jsonnet') +
{
  _config+:: {
    local config = self,
    environment: '{env}',
    synapse+: {
      replicas: 1,
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
      },
    },
    appservicePolicies+:{
      appservice+: {
        logLevel: "DEBUG",
        skipMessage: "true"
      },
    },
    matrixMediaRepo+: {
      mediarepo+: {     
        repo+: {
          logLevel: "INFO",  
        },
      },
    },
    clamav+:{
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
    }
  },
}
```

## Generate secrets 

```
docker run -it  -e SYNAPSE_SERVER_NAME=matrix-dev.eclipse.org -e SYNAPSE_REPORT_STATS=no -v $PWD/config/gen:/data docker.io/eclipsecbi/synapse:latest generate
```

Get secrets: `registration_shared_secret`, `macaroon_secret_key`, `form_secret` from files `./config/gen/homeserver.yaml` 
And store the signing keys from file: `./config/gen/matrix-dev.eclipse.org.signing.key`

For all other passwords, use your own password generator like `pwgen`.

Store passwords in pass with this organization:

```shell
IT/services/chat-service
├── appservice
│   ├── {env}
│   │   ├── asToken
│   │   └── hsToken
├── bot-mjolnir
│   ├── {env}
│   │   └── password
├── matrix-appservice-slack
│   └── {env}
│   │   ├── database_password
│   │   ├── asToken
│   │   └── hsToken
├── matrix-media-repo
│   ├── {env}
│   │   ├── database_password
│   │   ├── mmr.signing.key
│   │   └── synapse.mmr.signing.key
├── matrix-media-repo-keyserver
│   ├── {env}
|   │   ├── form_secret
|   │   ├── macaroon_secret_key
|   │   ├── merged.signing.key
|   │   ├── registration_shared_secret
|   │   └── signing.key
└── synapse
    ├── {env}
    │   ├── database_password
    │   ├── form_secret
    │   ├── macaroon_secret_key
    │   ├── oidc_providers_oauth2_eclipse_secret
    │   ├── registration_shared_secret
    │   ├── signing.key
    │   └── merged.signing.key
```

i.e: `pass add IT/services/chat-service/matrix-media-repo/staging-community/database_password`

Execute:  `./gen-secrets.sh`

It will store secrets under: `/environments/chat-matrix/<env>/.secrets`


### media repo signing key generation

https://docs.t2bot.io/matrix-media-repo/v1.3.5/installation/signing-key/

Download binaries here: 
* https://github.com/t2bot/matrix-media-repo/releases/download/v1.3.7/generate_signing_key-linux-x64
* https://github.com/t2bot/matrix-media-repo/releases/download/v1.3.7/combine_signing_keys-linux-x64


For each env generate a new signing.key 

```shell
./signing.sh <env>
```

Check keys: `https://matrix-<env>.eclipse.org/_matrix/key/v2/server`
Check keys: `https://matrix-media-repo-<env>.eclipse.org/_matrix/key/v2/server`

# Manual configuration

## Policy bot

### Configure rate limit

https://github.com/matrix-org/synapse/issues/6286

```sql
insert into ratelimit_override values ('@EF_policy_bot:matrix.eclipse.org', 0, 0);
```

## Moderation with Mjolnir/pantalaimon

NOTE: must be admin!

```
UPDATE users SET name = admin='1' where name='@usertest:matrix-local.eclipse.org';
```

Before starting: Clean mjolnir and pantalaimon local storage (not production) if exist: 

```shell
sudo rm -Rf ./config/local/mjolnir/storage
sudo rm -Rf ./config/local/pantalaimon/local-matrix
sudo rm -Rf ./config/local/pantalaimon/pan.db
```

IMPORTANT:
Activate temporary homeserver password config the time to configure bot for first login. 

file: `lib/chat-matrix/synapse/config-homeserver.libsonnet`

```json
password_config: {
  enabled: false,
},
```

1. create moderator user: `@ef_moderator_bot:matrix-local.eclipse.org`

Get password from pass: /IT/services/chat-service/bot-mjolnir/{env}/password

```shell
MATRIX_URL="https://matrix-local.eclipse.org"
ACCESS_TOKEN="YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY"

curl -k -s -X PUT \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -d '{"displayname": "Eclipse Foundation Moderator Bot", "password": "XXXXXXXXXXXXXXXX"}' \
    "${MATRIX_URL}/_synapse/admin/v2/users/@ef_moderator_bot:${MATRIX_URL##*://}"
```

return:

```json
{"name":"@ef_moderator_bot:matrix-local.eclipse.org","is_guest":0,"admin":false,"consent_version":null,"consent_ts":null,"consent_server_notice_sent":null,"appservice_id":null,"creation_ts":1681830226,"user_type":null,"deactivated":false,"shadow_banned":false,"displayname":"Eclipse Foundation moderator","avatar_url":null,"threepids":[],"external_ids":[],"erased":false}% 
```

2. Accept consent policy: Need to connect to the web interface with user `ef_moderator_bot` or calculate consent url.

Param openssl hmac is `form_secret`property in `homeserver.yaml`:

```shell
echo -n 'ef_moderator_bot' | openssl sha256 -hmac '15,CKuwubYD^2m2II.aQhRpf9gu37I9f.2kQv2-b^aHTz,UtMT'
```

```
https://matrix-local.eclipse.org/_matrix/consent?u=ef_moderator_bot&h=92cf81f3db94ded5387a0cc4c7b8138409f13f9d4b0ae2ee130923209531d0b9
```

go and accept!

3. Moderation room creation

via UI:
Room creation:
  * Name: `Chat Service moderation`
  * Alias: `#eclipsefdn.chat-moderation:matrix-local.eclipse.org` 
  * `private` 
  * `encrypt`

Add room to `#eclipsefdn:matrix.eclipse.org` space. (not mandatory for local tests)

via script:

```shell
MATRIX_URL="https://matrix-local.eclipse.org"
ACCESS_TOKEN="YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY"
curl -s -X POST --insecure \
                -H "Content-Type: application/json" \
                -H "Authorization: Bearer ${ACCESS_TOKEN}" \
                -d '{"preset":"trusted_private_chat", "name": "Chat Service moderation", "room_alias_name": "eclipsefdn.chat-moderation", "topic":"Room moderation with mjolnir for chat service", "invite": ["@ef_moderator_bot:matrix-local.eclipse.org"]}' \
                "${MATRIX_URL}/_matrix/client/r0/createRoom"
```

return: 

```json
{"room_id":"!RkEPsVKweWTdfyMCUH:dev.matrix.eclipsecontent.org"}
```

Attach to `eclipsefdn` space:

```shell
MATRIX_URL="https://matrix-local.eclipse.org"
ACCESS_TOKEN="YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY"
SPACE_ALIAS="%23eclipsefdn%3A${MATRIX_URL##*://}"
SPACE_ID=$(curl -s --insecure -H "Authorization: Bearer $ACCESS_TOKEN" "${MATRIX_URL}/_matrix/client/v3/directory/room/${SPACE_ALIAS}"|jq -r '.room_id')
ROOM_ALIAS="%23eclipsefdn.chat-moderation%3A${MATRIX_URL##*://}"
ROOM_ID=$(curl -s --insecure -H "Authorization: Bearer $ACCESS_TOKEN" "${MATRIX_URL}/_matrix/client/r0/directory/room/${ROOM_ALIAS}"|jq -r '.room_id')
curl -s -X PUT --insecure \
                -H "Content-Type: application/json" \
                -H "Authorization: Bearer ${ACCESS_TOKEN}" \
                -d '{"via":["matrix-local.eclipse.org"],"suggested":false}' \
                "${MATRIX_URL}/_matrix/client/r0/rooms/${SPACE_ID}/state/m.space.child/${ROOM_ID}"
```

Return: 

```json
{"event_id":"$5lBc6twDKWviKsn3tqKUiAEd-SAnbZiprGklIri1OF4"}
```

4. Add user `ef_moderator_bot` as `admin` if not set.

5. Set rate limit:

```sql
insert into ratelimit_override values ('@ef_moderator_bot:matrix-local.eclipse.org', 0, 0);
```

or via curl: 

```shell
MATRIX_URL="https://matrix-local.eclipse.org"
ACCESS_TOKEN="YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY"


curl -k -s -X POST \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -d '{"messages_per_second": 0, "burst_count": 0}' \
    "${MATRIX_URL}/_synapse/admin/v1/users/@ef_moderator_bot:${MATRIX_URL##*://}/override_ratelimit"
```

### Mjolnir default ACL

1. give temporary permission to moderator bot to create room with module `UserControlModule`

```json
modules: [
          {
            module: 'synapse.modules.synapse_user_control.UserControlModule',
            config: {
              creators: [
                ...
                '@ef_moderator_bot:' + mxDomain,                
              ],
            },
          }
```

2. Create first banlist: `!list create EF eclipsefdn.chat-moderation-bl`
2. Set banlist as default: `!default EF`
3. Add Community Moderation Effort: 
    * First join these room with your account otherwise you'll get: `error: "Can't join remote room because no servers that are in the room have been provided."`
    * !watch #community-moderation-effort-bl:neko.dev (see: https://blog.neko.dev/posts/)matrix-year-in-review-2022.html
    * !watch #matrix-org-hs-tos-bl:matrix.org
4. Sync banlist: `!sync`


Example of ACL for a specific matrix server: `!ban EF server matrix-local.eclipse.fr Known for spam` 

### Room moderation configuration

At room level:

1. Invite bot moderation to all rooms with custom level like `60`
2. Change ACL with custom level like `60`
3. Verify with `!verify`

At space level: just add `moderator` power level to bot.

NOTE: `!verify` show an error for space `eclipsefdn - Missing power level for server ACLs: 50 < 100`

### Activate protections

Protections list: `!protections`

### LocalAbuseReports

```!enabled LocalAbuseReports```

put nginx configuration:

```conf
  location ~ ^/_matrix/client/(r0|v3)/rooms/([^/]*)/report/(.*)$ {
    set $room_id $2;
    set $event_id $3;
    proxy_pass http://127.0.0.1:8082/api/1/report/$room_id/$event_id;
  }
```

## Slack integration (Appservice-Slack)

### Configure slack App

see: https://matrix-appservice-slack.readthedocs.io/en/stable/link_channels/

1- Create a Slack App (Classic): https://api.slack.com/apps?new_classic_app=1

```
App Name: `matrix-bridge`
Development Slack Workspace: choose the right slack workspace for the Slack App.
```

Select the `matrix-bridge`. Under `Features` Menu -> `App Home`-> First, add a legacy bot user 

```
Display Name (Bot Name): `Eclipse Foundation Matrix Bridge Bot`
Default username: `ef_matrix_bridge_bot`
```

2- Create `OAuth & Permissions`

 Under `Features` Menu -> `OAuth & Permissions`
 
Click `Install to Workspace` button

Get User OAuth Token and Bot User OAuth Token and store in pass.

```
/IT/services/chat-service/slack-integration/<app>/bot-user-oauth-token
```

### Create matrix admin room

Create a private room: `#eclipsefdn.chat-slack:matrix.eclipse.org` with Name: `Chat Service Slack Admin`.
And attach to space: `#eclipsefdn:matrix.eclipse.org`.

IMPORTANT: Must not be encrypt!

Set the ID in the configuration: 

i.e:

```
matrix_admin_room: !abcdefg12345hijk:matrix.eclipse.org
```

### invite slack bot in room

```
/invite @ef_slack_bridge_bot:matrix.eclipse.org
```

Even if the bot is not recognized.

### slack bot rate limit

https://github.com/matrix-org/synapse/issues/6286

```sql
insert into ratelimit_override values ('@ef_slack_bridge_bot:matrix.eclipse.org', 0, 0);
```

Need a restart!

### Set the right admin room

It might possible that the bridge set another room that the one previously created.
This can be force by updating database;

```sql
update user_admin_rooms set roomid='!becqmCHUKvDiueefgt:matrix-staging.eclipse.org' where matrixuser='-internal-';
```

## Link a chat service room to a slack channel

1- On Chat service room 

- Invite bot `ef_slack_bridge_bot` to room on chat service.

```
/invite @ef_slack_bridge_bot:matrix.eclipse.org
```

- Get room_id from settings -> Advanced -> Internal room ID
ex: `!xxxxxxxxxxxxxx:matrix.eclipse.org`


2- On slack room

- Add app matrix-bridge on slack channel

Right click on slack room channel -> `View channel details`  -> `Integration` -> `Add apps` 
Select `matrix-bridge`

- Invite bot `ef_matrix_bridge_bot` to room on chat service.

```
/invite ef_matrix_bridge_bot
```

- Get channel ID

Right-click your channel name in Slack and select “Copy Link”. The channel id is the last argument in the url.

Get the Id from the URL: `https://XXX.Slack.com/messages/<channel id>/`

3- Link rooms

In the chat service admin room: `Chat Service Slack Admin`

```
link --channel_id YYYYYYYY --room !xxxxxxxxxxxxxx:matrix.eclipse.org --slack_bot_token xoxb-xxxxxxxxxxxxxxxx
```

`Eclipse Foundatino Slack Bridge Bot` should write:

```
Room is now pending-name
Remember to invite the slack bot to the slack channel.
```

# Devops

## Generate secrets

Execute:  `./gen-secrets.sh`

It will store secrets under: `/environments/chat-matrix/{env}/.secrets`

## tanka

see doc installation tanka: `https://tanka.dev/install`

```shell
tk show "environments/chat-matrix/dev"
tk apply "environments/chat-matrix/dev"
```

Exporting kubernetes files:

```shell
tk show --dangerous-allow-redirect "environments/chat-matrix/dev" > ./k8s/chat-matrix-dev.yaml
```

## Apply.sh script

Allow to run tanka and apply modification with kubectl for an environment.

```
./apply.sh {env}
```

## kubectl status

Installation

```
kubectl krew install status
```

```
kubectl status deployment -n chat-matrix-dev
```

# Upgrade 

## Synapse

### Check changelog

First check changelog, ex: `https://github.com/matrix-org/synapse/releases/tag/v1.82.0`

Look at :
* Module signature deprecation: impact `modules/synapse_prevent_encrypt_room`, `modules/synapse_user_control`, `modules/synapse_user_restrictions`) 
* OIDC changes: impact `/synapse/config/oidc.py`, `/synapse/handlers/oidc.py` 
* Templates: impact `/synpase/res/templates`
* Configuration files: Configuration changes should be apply in this configuration file: `/lib/chat-matrix/synapse/config-homeserver.libsonnet`.
* New features!

### Upgrade version

Check version and look for dockerhub tags: `https://hub.docker.com/r/matrixdotorg/synapse/tags`

And apply change in docker image file: `/docker/Dockerfile.synapse`

```
ARG SYNAPSE_VERSION="v1.82.0"
```

Commit with message: `feat: upgrade synapse to v1.82.0`
gitmoji: `⬆️  - Upgrade dependencies.`

Push/Wait for CI building synapse image and apply changes in kubernetes: `./apply.sh {env}`

## Matrix-media-repo

### Check changelog

First check changelog, ex: `https://github.com/turt2live/matrix-media-repo/releases/tag/v1.2.13`

Look for compatibilities with synapse version.
Look for changes in API, cors, everything that could impact nginx rewrite rules.

### Upgrade version

Note: Media repo version is currently a specific tag for two reasons:
* tag 1.2.13 missing some features
* last commit failed CI

Apply change in docker image file: `/docker/Dockerfile.mediarepo`

```
ARG CLONE_BRANCH="master" 
ARG CO_SHA="219e4bc67ab8e354b263774aca0118332ea48c25" 
```

Commit with message: `feat: upgrade mediarepo to branch XXXXXXX and commit XXXXXXXXXXXX`
gitmoji: `⬆️  - Upgrade dependencies.`

Push/Wait for CI building synapse image and apply changes in kubernetes: `./apply.sh {env}`

## Synapse-admin

### Check changelog

First check changelog, ex: `https://github.com/Awesome-Technologies/synapse-admin/releases/tag/0.8.7`

### Upgrade version

Check version and look for github branch tags: `https://github.com/Awesome-Technologies/synapse-admin/tree/0.8.7`

Apply change in docker image file: `/docker/Dockerfile.admin`

```
ARG SYNAPSE_ADMIN_BRANCH="0.9.1"
```

Commit with message: `feat: upgrade synapse-admin to 0.8.7 `
gitmoji: `⬆️  - Upgrade dependencies.`

Push/Wait for CI building synapse image and apply changes in kubernetes: `./apply.sh {env}`


# Maintenance

## Compress state

Compress state cronjob is based on project: https://github.com/matrix-org/rust-synapse-compress-state and runs daily.

Run manually a job: 

```shell 
JOB_NAME="${USERNAME}-manual-compress-state-run-$(date +"%s")"
kubectl create job -n chat-matrix-prod --from=cronjob/synapse-compress-state ${JOB_NAME}
```

# Development

## register new user

```shell
sudo docker exec -it $(sudo docker ps -aqf "name=synapse"|head -n 1) register_new_matrix_user -u test -p test -a -c /synapse/config/homeserver.yaml http://localhost:8008
```

## list users

```shell
docker exec -it $(sudo docker ps -aqf "name=postgres"|head -n 1) psql -U synapse -d synapse -c "SELECT * FROM users;"
```

## set admin

```shell
docker exec -it $(sudo docker ps -aqf "name=postgres"|head -n 1) psql -U synapse -d synapse -c "UPDATE users SET admin = 1 WHERE name = '@test:matrix-local.eclipse.org';"
```

## change rate limit

```shell
docker exec -it $(sudo docker ps -aqf "name=postgres"|head -n 1) psql -U synapse -d synapse -c "insert into ratelimit_override values ('@test:matrix-local.eclipse.org', 0, 0);"
```

Need a restart!

## Reuse lint

```shell
docker run -v $PWD:/data fsfe/reuse:latest lint
```

## Docker-compose render

```shell
docker run --rm -it --name dcv -v $(pwd):/input pmsipilot/docker-compose-viz render -m image docker-compose.yaml
```

## k8s render

```shell
./k8sviz.sh -n chat-matrix-prod -t png -o k8s-architecture.png
```

# Usefull links

Matrix version and features: 

```
https://matrix.eclipse.org/_matrix/client/versions
https://matrix.eclipse.org/_matrix/federation/v1/version
```