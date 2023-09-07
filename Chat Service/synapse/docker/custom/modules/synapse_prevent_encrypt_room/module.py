import logging
import synapse
from typing import Optional, Tuple, Union
from synapse import module_api
from synapse.module_api.errors import ConfigError

logger = logging.getLogger(__name__)

# source: https://raw.githubusercontent.com/digitalentity/matrix_encryption_disabler/main/matrix_e2ee_filter.py


class SynapsePreventEncryptRoom:

    def __init__(self, config: dict, api: module_api):
        self.api = api
        self.api.register_spam_checker_callbacks(check_event_for_spam=self.check_event_for_spam,)
        self.allow_rooms = config.get("allow_encryption_for_rooms", [])
        self.allow_senders = config.get("allow_encryption_for_users", [])
        self.deny_user_servers = config.get("deny_encryption_for_users_of", [])
        self.deny_room_servers = config.get("deny_encryption_for_rooms_of", [])
        self.allow_user_servers = config.get("allow_encryption_for_users_of", [])
        self.allow_room_servers = config.get("allow_encryption_for_rooms_of", [])
        logger.info('Registered custom rule filter: EncryptedRoomFilter')

    async def check_event_for_spam(self, event: "synapse.events.EventBase") -> Union["synapse.module_api.NOT_SPAM", "synapse.module_api.errors.Codes"]:
        # This is probably unnecessary if m.room.power_levels are set correctly
        # Let's keep it just in case
        event_dict = event.get_dict()
        try:
            event_type = event_dict.get('type', None)
            logger.info('check_event_for_spam event: %s', event_dict)
            if event_type == 'm.room.encryption':
                sender = event_dict.get('sender', '<unknown>')
                room_id = event_dict.get('room_id', '<unknown>')
                _, user_server = event_dict['sender'].split(':', 2)
                _, room_server = event_dict['room_id'].split(':', 2)

                if room_id in self.allow_rooms:
                    logger.info('Allow E2EE for %s / room server', room_id)                
                elif sender in self.allow_senders:
                    logger.info('Allow E2EE for %s / sender', sender)
                elif user_server in self.deny_user_servers:
                    logger.warn('Denied E2EE for %s / requestor', event_dict.get('room_id', '<unknown>'))
                    return synapse.module_api.errors.Codes.FORBIDDEN
                elif room_server in self.deny_room_servers:
                    logger.warn('Denied E2EE for %s / room server', event_dict.get('room_id', '<unknown>'))
                    return synapse.module_api.errors.Codes.FORBIDDEN      
                elif user_server in self.allow_user_servers:
                    logger.info('Allow E2EE for %s / requestor', event_dict.get('room_id', '<unknown>'))
                elif room_server in self.allow_room_servers:
                    logger.info('Allow E2EE for %s / room server', event_dict.get('room_id', '<unknown>'))           
                else:
                    logger.warn('Forbidden E2EE for %s / room server', event_dict.get('room_id', '<unknown>'))
                    return synapse.module_api.errors.Codes.FORBIDDEN
        except Exception:
            logger.warn('Exception when trying to handle the event: %s', event_dict)
            return synapse.module_api.errors.Codes.FORBIDDEN
        return synapse.module_api.NOT_SPAM


    @staticmethod
    def parse_config(config):
        if config == None:
            raise ConfigError('Missing config for Pevent Encrypt Room module')
        return config
