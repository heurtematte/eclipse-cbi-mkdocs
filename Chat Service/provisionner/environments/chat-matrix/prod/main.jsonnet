(import 'chat-matrix/main.libsonnet') +
(import '.secrets/secrets.jsonnet') +
{
  _config+:: {
    local config = self,
    environment: 'prod',
    chatServiceSync+:{
      active:true,
      project: std.parseYaml(importstr '../../../project.yaml'),
      config+: {
        logLevel: 'INFO',
        dry: "false",
      }
    },
  },
}
