(import 'chat-matrix/main.libsonnet') +
(import '.secrets/secrets.jsonnet') +
{
  _config+:: {
    local config = self,
    environment: 'dev',
    matrixDomain: 'matrix.eclipsecontent.org',
    chatDomain: 'chat.eclipsecontent.org',
    chatServiceSync+:{
      active:true,
      schedule: '0/5 * * * *', #every 5 minutes
      project: std.parseYaml(importstr '../../../project.yaml'),
    },
  },
}
