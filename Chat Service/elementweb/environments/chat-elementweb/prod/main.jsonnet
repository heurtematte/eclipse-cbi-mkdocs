
(import "chat-elementweb/main.libsonnet") +
{
    _config+:: { 
        environment: "prod",
        elementweb+: {
            replicas: 1,
            config+:{
                "redirectRegistrer": "https://accounts.eclipse.org/user/register?destination=user",
            },
        }
    }
}
