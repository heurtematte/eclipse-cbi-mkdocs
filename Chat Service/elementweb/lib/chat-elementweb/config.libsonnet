
local util = import './util.libsonnet';

{
  _config+:: {    
    organization: 'org.eclipse.chat.elementweb',
    name: 'elementweb',
    namespace: 'chat-elementweb-' + self.environment,
    environment: 'local', 
    matrixDomain: 'matrix.eclipse.org',
    chatDomain: 'chat.eclipse.org'
  },
}
