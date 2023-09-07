import logging

from synapse.api.errors import SynapseError
from synapse.module_api import ModuleApi
from synapse.module_api.errors import ConfigError

logger = logging.getLogger(__name__)

class UserControlModule:

    def __init__(self, config, api: ModuleApi):          
        self._api = api
        self._config = config
        self._api.register_third_party_rules_callbacks(
            on_create_room=self.on_create_room,
        )

        logger.debug('======== Domain Rules Module init ========')
        self.creators = config['creators']
        logger.debug('=== debug creators ===')
        logger.debug('* type: ' + type(self.creators).__name__)
        logger.debug('* values: ' + ', '.join("%s" % i for i in self.creators))
        logger.debug('======== end init of Domain Rules Module ========')

    async def on_create_room(self, requester, config, is_requester_admin)-> None: 
        logger.debug('======== Domain Rules Module on_create_room ========')
        logger.debug('=== full requester ===')
        logger.debug('* type: ' + type(requester).__name__)
        logger.debug('* name: ' + requester.user.to_string())
        logger.debug('=== debug config ===')
        logger.debug('* keys and values:')
        logger.debug("* Got event keys: %s.", config.keys())
        logger.debug("* Got event values: %s.", config.values())
        if requester.user.to_string() in self.creators:
            logger.info('=== Room created by authorized person ===')
        elif 'is_direct' in config.keys():
            logger.info('=== Room for direct conversation ===')
        elif is_requester_admin:
            logger.info('=== Room created by admin ===')
        else:
            logger.info('=== Room creation not permitted ===')
            raise SynapseError(403, "You are not permitted to create rooms")

    @staticmethod
    def parse_config(config):
        if config == None:
            raise ConfigError('Missing config for User Control Module')
        if 'creators' not in config:
            raise ConfigError('Missing creators parameter for User Control Module')
        return config


 
