module.exports = {
    logLevel: process.env.SYNC_LOG_LEVEL || "INFO",
    dry: process.env.SYNC_DRY || true,
    projectConfigFile: process.env.SYNC_PROJECT_CONFIG_FILE || __dirname + `/project.yaml`,
    matrixAPI: { 
        baseUrl: process.env.SYNC_PERMS_HOMESERVER_URL || "https://matrix-local.eclipse.org", 
        accessToken: process.env.SYNC_PERMS_HOMESERVER_TOKEN || "XXXXXXXXXXXXX",
        matrixDomain: process.env.SYNC_PERMS_HOMESERVER_DOMAIN || "matrix-local.eclipse.org", 
    },
    eclipseAPI: {
        userAPIBaseUrl: process.env.SYNC_ECLIPSE_USER_API_BASE_URL || 'https://api.eclipse.org',
        projectAPIBaseUrl: process.env.SYNC_ECLIPSE_PROJECT_API_BASE_URL || 'https://projects.eclipse.org',
        oauth: {
            client: {
                id: process.env.SYNC_ECLIPSE_API_OAUTH_CLIENT_ID || 'XXXXXXXXXXXXX',
                secret: process.env.SYNC_ECLIPSE_API_OAUTH_SECRET || 'XXXXXXXXXXXXXX',
            },
            auth: {
                tokenHost: process.env.SYNC_ECLIPSE_API_OAUTH_AUTH_TOKEN_HOST || 'https://accounts.eclipse.org',
                tokenPath: process.env.SYNC_ECLIPSE_API_OAUTH_AUTH_TOKEN_PATH || '/oauth2/token',
            }
        },
        additionnalOauth: {
            timeout: parseInt(process.env.SYNC_ECLIPSE_API_ADDITIONNALOAUTH_TIMEOUT) || 3600,
            scope: process.env.SYNC_ECLIPSE_API_ADDITIONNALOAUTH_SCOPE ||  'eclipsefdn_view_all_profiles'
        },
    }
}