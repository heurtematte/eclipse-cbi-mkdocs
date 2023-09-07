
// SPDX-FileCopyrightText: 2023 eclipse foundation
// SPDX-License-Identifier: EPL-2.0

import { Logger } from 'sitka';

const utils = require('matrix-js-sdk/lib/utils');
import { EventType, ISendEventResponse, MatrixClient, MatrixError, Method } from 'matrix-js-sdk';
import { IDefaultConfig, IRoom, IRoomPowerLevel } from '../../entity/config';
import { MatrixUtils } from '../utils/matrix-utils';
import { IRoomEncryption } from 'matrix-js-sdk/lib/crypto/RoomList';
const markdownIt = require('markdown-it');
const md = new markdownIt();

export default class MatrixRoomService {

    log: Logger;

    client: MatrixClient;
    defaultConfig: IDefaultConfig;
    dry: boolean;

    constructor(matrixClient: MatrixClient, defaultConfig: IDefaultConfig, matrixDomain: string, logCtx: string, dry: boolean) {
        this.client = matrixClient;
        this.defaultConfig = defaultConfig;
        this.dry = dry;

        this.log = Logger.getLogger(`${logCtx}/MatrixRoomService`);
    }

    async createRoomWithDetails(room: IRoom): Promise<{ room_id: string }> {

        const roomDetails = await this.createRoom(room);

        await this.setEncryption(roomDetails.room_id, room);
        await this.setAvatar(roomDetails.room_id, room);
        await this.attachRoomToSpace(roomDetails.room_id, room);

        return roomDetails;
    }

    async attachRoomToSpace(roomId: string, room: IRoom) {
        const roomSpaces = room.parent ? (Array.isArray(room.parent) ? room.parent : [room.parent]) : [];
        for (let space of roomSpaces.flat()) {
            const spaceFullAlias = MatrixUtils.getRoomAliasFormat(space);
            let spaceDetails;
            try {
                spaceDetails = await this.client.getRoomIdForAlias(spaceFullAlias);
            } catch (e) {
                this.log.error(`Error while searching for space alias: ${spaceFullAlias}`, e);
                return;
            }
            try {
                const eventResponse = await this.requestAttachToSpace(roomId, room, spaceDetails.room_id, spaceFullAlias);
                this.log.info(`Response of attach room ${room.alias} to space ${spaceFullAlias} , event: ${JSON.stringify(eventResponse)}`);
            } catch (e) {
                this.log.error(`Error while attach room ${room.alias} to space ${spaceFullAlias}`, e);
            }
        }
    }

    async createRoom(room: IRoom): Promise<{ room_id: string }> {
        if (this.dry) {
            this.log.info(`DRY MODE: room ${room.alias} creation`);
            return { room_id: "" };
        } else {
            this.log.info(`Create ${room.type || "room"} with alias ${room.alias}...`);

            let space;
            if (room.type == 'space')
                space = {
                    creation_content: {
                        "type": "m.space"
                    },
                }
            const roomEvent = await this.client.createRoom({
                room_alias_name: room.alias.replace(/#/g, ''),
                visibility: room.visibility || this.defaultConfig.roomVisibility,
                name: room.name,
                // topic: room.topic,
                preset: room.preset || this.defaultConfig.roomPreset,
                power_level_content_override: room.powerLevel || this.defaultConfig.roomPowerLevel,
                ...space
            });

            if (roomEvent.room_id && room?.topic) {
                const eventResponse = await this.client.setRoomTopic(roomEvent.room_id, room.topic, md.render(room.topic));
                this.log.info(`Response of create ${room?.type} ${room.alias} with topic: '${room.topic}', event: ${JSON.stringify(eventResponse)}`);

                await this.setExtraAlias(roomEvent.room_id, room);
            }
            return roomEvent;
        }
    }

    async updateRoom(roomId: string, room: IRoom) {
        if (this.dry) {
            this.log.info(`DRY MODE: update room ${room.alias}`);
        } else {
            this.log.info(`Update room ${room.alias}...`);

            await this.setRoomName(roomId, room);
            await this.setTopic(roomId, room);
            await this.setEncryption(roomId, room);
            await this.setExtraAlias(roomId, room);
            await this.setAvatar(roomId, room);
            await this.attachRoomToSpace(roomId, room);
        }
    }

    private async setRoomName(roomId: string, room: IRoom) {
        if (room.name) {
            try {
                const eventResponse = await this.client.setRoomName(roomId, room.name);
                this.log.info(`Response of update room ${room.alias} with Name: '${room.name}', event: ${JSON.stringify(eventResponse)}`);
            } catch (e) {
                this.log.error(`Update room name for room ${room.alias} is not possible`, e);
            }
        } else {
            this.log.warn(`Update room name is not possible, cause it's not defined for ${room.alias}`);
        }
    }

    private async setTopic(roomId: string, room: IRoom) {
        if (room.forceUpdate && room?.topic) {
            try {
                const eventResponse = await this.client.setRoomTopic(roomId, room.topic, md.render(room.topic));
                this.log.info(`Response of update room ${room.alias} with topic: '${room.topic}', event: ${JSON.stringify(eventResponse)}`);
            } catch (e) {
                this.log.error(`Update room topic for room ${room.alias} failed`, e);
            }
        }
    }

    private async setEncryption(roomId: string, room: IRoom) {
        if (room.encryption !== undefined && room.encryption) {
            if (this.client.isRoomEncrypted(roomId)) {
                this.log.info(`Room already encrypted ${room.alias} with Name: '${room.name}'`);
            } else {
                try {
                    const eventResponse = await this.client.setRoomEncryption(roomId, { algorithm: "m.megolm.v1.aes-sha2" } as IRoomEncryption);
                    this.log.info(`Response of update room encryption ${room.alias} with Name: '${room.name}', event: ${JSON.stringify(eventResponse)}`);
                } catch (e) {
                    this.log.error(`Update room encryption for room ${room.alias} is not possible`, e);
                }
            }
        }
    }

    private async setExtraAlias(roomId: string, room: IRoom) {
        const extraAliasArray = room.extraAlias ? (Array.isArray(room.extraAlias) ? room.extraAlias : [room.extraAlias]) : [];
        let altAliases = [];

        //create all alias
        for (const extraAlias of extraAliasArray) {
            let roomAlias = MatrixUtils.getRoomAliasFormat(extraAlias);
            altAliases.push(roomAlias)
            try {
                let eventAliasResponse = await this.client.createAlias(roomAlias, roomId);
                this.log.info(`Response of create ${room?.type} ${room.alias} with alias: '${extraAlias}', event: ${JSON.stringify(eventAliasResponse)}`);
            } catch (e) {
                if ((<MatrixError>e).httpStatus == 429) {
                    this.log.info(`Room aliases ${roomAlias} for room ${room.alias} already exist`);
                }else{
                    this.log.error(`Update room alias for room ${room.alias} failed`, e);
                }
            }
        }

        // set canonical alias
        const path = utils.encodeUri("/rooms/$roomId/state/m.room.canonical_alias", {
            $roomId: roomId
        });
        const body = {
            alias: MatrixUtils.getRoomAliasFormat(room.alias),
            alt_aliases: altAliases
        };
        try {
            await this.client.http.authedRequest(Method.Put, path, undefined, body);
        } catch (e) {
            this.log.error(`Update room alias for room ${room.alias} failed`, e);
        }

    }

    async setAvatar(roomId: string, room: IRoom): Promise<ISendEventResponse> {
        return { event_id: "" };

        // if (this.dry) {
        //     this.log.info(`DRY MODE: room ${room.alias} set avatar`);
        //     return { event_id: "" };
        // } else {
        //     this.log.info(`Room ${room.alias} set avatar`);

        //     if(room.avatar !== undefined){

        //         const uploadResponse = await this.client.uploadContent(room.avatar);

        //         const path = utils.encodeUri("/rooms/$roomId/state/m.room.avatar", {
        //             $roomId: roomId
        //         });
        //         this.log.info(`Call ${path}`);
        //         return this.client.http.authedRequest(Method.Put, path, undefined, uploadResponse.content_uri);
        //     }else{ 
        //         this.log.warn(`No avatar for room  ${room.alias}`)
        //         return { event_id: "" };
        //     }      
        // }   
    }


    async requestAttachToSpace(roomId: string, room: IRoom, spaceId: string, spaceAlias: string): Promise<ISendEventResponse> {
        if (this.dry) {
            this.log.info(`DRY MODE: attach room ${room.alias} to space ${spaceAlias}`);
            return { event_id: "" };
        } else {
            this.log.info(`Attach room ${room.alias} to space ${spaceAlias}!!!`);
            return this.client.sendStateEvent(
                spaceId,
                EventType.SpaceChild,
                {
                    via: [MatrixUtils.getDomain()],
                },
                roomId,
            );
        }
    }

    async setPowerLevel(
        roomId: string,
        roomAlias: string,
        userId: Record<string, number | null> | Record<string, number | null>[],
        defaultContent: IRoomPowerLevel,
        defaultPowerLevel: number,
    ): Promise<ISendEventResponse> {
        if (this.dry) {
            this.log.info(`DRY MODE: room ${roomAlias} set with new power level`);
            return { event_id: "" };
        } else {
            this.log.info(`Room ${roomAlias} set with new power level`);

            let content = { ...utils.deepCopy(defaultContent), users: {} };

            if (Array.isArray(userId)) {
                for (const user of userId) {
                    content.users[Object.keys(user)[0]] = (Object.values(user)[0] || defaultPowerLevel);
                }
            } else {
                content.users = userId;
            }

            const path = utils.encodeUri("/rooms/$roomId/state/m.room.power_levels", {
                $roomId: roomId
            });
            this.log.info(`Call ${path} with content: ${JSON.stringify(content)}`);
            return this.client.http.authedRequest(Method.Put, path, undefined, content);
        }
    }
}