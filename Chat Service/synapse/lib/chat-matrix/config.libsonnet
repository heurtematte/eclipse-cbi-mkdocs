
local util = import './util.libsonnet';

{
  _config+:: {    
    organization: 'org.eclipse.chat.matrix',
    name: 'synapse',
    namespace: 'chat-matrix-' + self.environment,
    environment: 'local', 
    matrixDomain: 'matrix.eclipse.org',
    matrixMediaRepoDomain: 'matrix-media-repo.eclipsecontent.org',
    chatDomain: 'chat.eclipse.org',
    synapseAdminDomain: 'synapse-admin.eclipse.org',
    mjolnirDomain: 'mjolnir.eclipse.org',
    // appservicePoliciesDomain: 'appservice-policies.eclipse.org',
    appserviceSlackDomain: 'appservice-slack.eclipsecontent.org',
  },
}
