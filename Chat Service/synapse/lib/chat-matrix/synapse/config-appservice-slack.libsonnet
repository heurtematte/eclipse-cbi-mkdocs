// local util = import '../util.libsonnet';

// (import '../appservice-policies/config-appservice.libsonnet') +
// {
//   _config+:: {
//     local config = self,
//     local mxDomain = util.getDomain(config.matrixDomain, config.environment),

//     synapse+: {
//       appserviceSlack+: {
//         id: 'appservice_slack',
//         url: 'http://appservice-policies' ,
//         "as_token": config.appserviceSlack.appservice.asToken,
//         "hs_token": config.appserviceSlack.appservice.hsToken,
//         sender_localpart: config.appserviceSlack.appservice.botName,
//         namespaces: {
//           users: [
//             {
//               exclusive: true,
//               regex: '@'+ config.appserviceSlack.appservice.username_prefix +'.*:' + mxDomain,
//             },
//           ]
//         },

//       },
//     },
//   },
// }
