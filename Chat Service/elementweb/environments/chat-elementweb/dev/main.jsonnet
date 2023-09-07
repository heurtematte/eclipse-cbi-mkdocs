(import "chat-elementweb/main.libsonnet") +
{
    _config+:: { 
        environment: "dev",
        matrixDomain: 'matrix.eclipsecontent.org',
        chatDomain: 'chat.eclipsecontent.org',
        
        elementweb+: {
            config+:{
                "broadcast": "Eclipse foundation chat service 'DEV' environment",
                'show_labs_settings': true,

                // 'setting_defaults'+: {
                //     'UIFeature.voip': true,
                // },
                // "jitsi"+: {
                //     "preferred_domain": "meet.element.io"
                // },
            },
        },
    }
}
