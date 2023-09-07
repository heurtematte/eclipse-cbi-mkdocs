
workspace {

    model {
        userEclipseAccount = person "Eclipse Account User" "An Eclipse Foundation account user."
        userFederatedAccount = person "User Federated" "An Matrix federated account user."

        elementweb = softwareSystem "ElementWeb" "chat.matrix.org"
        
        chatService = softwareSystem "Chat Service" {
            synapse = container "Synapse" "matrix.eclipse.org" {
                userEclipseAccount -> this "Uses"
                userFederatedAccount -> this "Uses"
            }
            container "Synapse Database" {
                synapse -> this "Reads from and writes to"
            }
            container "Elementweb" "chat.eclipse.org" {
                userEclipseAccount -> this "Uses"
            }
            matrixMediaRepo = container "Matrix-Media-Repo" "matrix-media-repo.eclipsecontent.org" {
                synapse -> this "Uses"
                userEclipseAccount -> this "Uses"
                userFederatedAccount -> this "Uses"
            }
            container "Matrix-Media-Repo Database" {
                matrixMediaRepo -> this "Reads from and writes to"
            }
            appservicePolicies = container "appservice-policies" "matrix-media-repo.eclipsecontent.org" {
                synapse -> this "Uses"
                this -> synapse "Uses"
            }
            
            botMjolnir = container "bot-mjolnir" "Moderation bot" {
                this -> synapse "Uses"
            }
            pantalaimon = container "pantalaimon" "Proxy for encrypt rooms" {
                botMjolnir -> this "Uses"
                this -> synapse "Uses"
            }
        }
        
        userEclipseAccount -> chatService "Uses"
        userFederatedAccount -> chatService "Uses"
        
      
    }

    views {
        systemContext chatService  {
            include *
            autoLayout
        }
        
        
        container chatService {
            include *
            autolayout lr
        }

        styles {
            element "Software System" {
                background #1168bd
                color #ffffff
            }
            element "Person" {
                shape person
                background #08427b
                color #ffffff
            }
        }
    }
    
}
