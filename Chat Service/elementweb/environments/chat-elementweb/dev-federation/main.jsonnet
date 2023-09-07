(import "chat-elementweb/main.libsonnet") +
{
    _config+:: { 
        environment: "dev-federation",
        matrixDomain: 'matrix.eclipsecontent.org',
        chatDomain: 'chat.eclipsecontent.org',
        elementweb+: {
            config+:{
                "broadcast": "Eclipse foundation chat service dev-federation instance",
                'show_labs_settings': true,
                'disable_3pid_login': false,
            },
        },
    }
}
