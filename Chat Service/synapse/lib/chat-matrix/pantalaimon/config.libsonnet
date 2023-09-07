local util = import '../util.libsonnet';

{
  local secret = $._secret,
   _config+:: {    
    local config = self,
    local mxDomain = util.getDomain(config.matrixDomain, config.environment),
    pantalaimon+: {
      
      "pantalaimon.conf"+: {
        main:{},
        sections: {
          Default: {
              LogLevel: "Debug",
              SSL: "True"
          },
          matrix: {
              Homeserver: "http://synapse",
              ListenAddress: "0.0.0.0",
              ListenPort: 8008,
              SSL: "False",
              UseKeyring: "False",
              IgnoreVerification: "True"
          }
        }
      },
    }
  },

}
