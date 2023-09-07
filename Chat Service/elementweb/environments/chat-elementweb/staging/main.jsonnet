
(import "chat-elementweb/main.libsonnet") +
{
    _config+:: { 
        environment: "staging",
        elementweb+: {
            replicas: 1,
            config+:{
                "redirectRegistrer": "https://accounts.eclipse.org/user/register?destination=user",
                "broadcast": "Eclipse foundation chat service 'STAGING' environment; End of this environment on April 21th",
            },
        }, 
    }
}
