
local util = import './util.libsonnet';

{
  _config+:: {    
    organization: 'org.eclipse.chat.matrix',
    name: 'synapse',
    namespace: 'chat-matrix-' + self.environment,
    environment: 'local', 
    matrixDomain: 'matrix.eclipse.org',
    chatDomain: 'chat.eclipse.org',
  },
}
