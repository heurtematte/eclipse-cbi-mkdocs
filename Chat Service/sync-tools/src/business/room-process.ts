// SPDX-FileCopyrightText: 2023 eclipse foundation
// SPDX-License-Identifier: EPL-2.0

import { ISendEventResponse, MatrixClient, MatrixError } from 'matrix-js-sdk';
import { Logger } from 'sitka';
import { IDefaultConfig, IRoom, userConfig, UserConfigDefinition } from '../entity/config';
import SynapseAdminApiUser from '../service/client/synapse-admin-api-user';
import { ProjectLeadService } from '../service/eclipse/project-lead-service';
import MatrixRoomService from '../service/matrix/room-service';
import { MatrixUtils } from '../service/utils/matrix-utils';


interface IJoinedMembers {
    [userId: string]: {
        display_name: string;
        avatar_url: string;
    };
}

export class RoomProcess{

	log: Logger;
	client: MatrixClient;
	defaultConfig: IDefaultConfig;
	matrixDomain: string;
	projectId: string;
	plUsersEmails: string[];
	room: IRoom;

	dry: boolean;

	roomService:MatrixRoomService;
	synapseUserAPI: SynapseAdminApiUser;

	projectLeadService:ProjectLeadService;

	constructor(eclipseAPIConfiguration:any, matrixClient: MatrixClient, defaultConfig: IDefaultConfig, matrixDomain: string, projectId: string, room: IRoom, plUsersEmails: string[], dry: boolean) {
		this.client = matrixClient;
		this.defaultConfig = defaultConfig;
		this.matrixDomain = matrixDomain;
		this.projectId = projectId;
		this.plUsersEmails = plUsersEmails;
		this.room = room;
		this.dry = dry;

		this.log = Logger.getLogger(`${projectId}/${room.alias}/RoomProcess`);

		this.roomService = new MatrixRoomService(matrixClient, defaultConfig, matrixDomain, `${projectId}/${room.alias}`, dry);
		this.synapseUserAPI = new SynapseAdminApiUser(matrixClient, `${projectId}/${room.alias}`);

		this.projectLeadService = new ProjectLeadService(eclipseAPIConfiguration, `${projectId}/${room.alias}`);
	}

	async processMatrixRoom() {

		this.log.info(`Process ${this.room.type || 'room'}: ${this.room.alias}, ${this.plUsersEmails}`);
    
		let roomDetails;
		const roomFullAlias = MatrixUtils.getRoomAliasFormat(this.room.alias);
		try {
			roomDetails = await this.client.getRoomIdForAlias(roomFullAlias)
			this.roomService.updateRoom(roomDetails.room_id, this.room);
		} catch (e) {
			if ((<MatrixError>e).errcode === 'M_NOT_FOUND') {
				try{
					roomDetails = await this.roomService.createRoomWithDetails(this.room);
				} catch (e) {
					this.log.error(`Error while creating room alias: ${roomFullAlias}`, e);
					return;
				}
			} else {
				this.log.error(`Error while searching for room alias: ${roomFullAlias}`, e);
				return;
			}
		}
    
		// test root project projectLead option, after room projectLead option and then room users definitions
		if (!this.plUsersEmails && !(this.room.projectLead !== undefined && this.room.projectLead) && this.room.users.length == 0) {
			this.log.warn('Room definition doesn\'t permit moderator configuration!');
			// TODO delete return when Configurationas code will be ready.
			return;
		}    

		try {
			let joinedMembers = {}
			if (roomDetails) {
				const members = await this.client.getJoinedRoomMembers(roomDetails.room_id);
				joinedMembers = members.joined;
			}
			const mxids = {
				...await this.processRoomUsersFromConfiguration(roomDetails.room_id, joinedMembers),
				...await this.processRoomProjectLead(joinedMembers)
			};
		
			await this.processPowerLevel(roomDetails.room_id, roomFullAlias, mxids);
		} catch (e) {
			this.log.error(`Error while setting power room alias: ${roomFullAlias}`, e);
			return;
		}
	}
        
    
	/**
     * Create a list of join room users which are project lead
     * @param joinedMembers list of all join room member
     * @returns list of all mxid with powerlevel associate to project lead
     */
	async processRoomProjectLead(joinedMembers: IJoinedMembers): Promise<userConfig> {
    
		let mxids: userConfig = {};

		let projectLeadList = this.plUsersEmails;

		function removeDuplicates(arr:string[]) {
			return arr.filter((item,
				index) => arr.indexOf(item) === index);
		}

		if (this.room.projectId){
			projectLeadList = removeDuplicates(projectLeadList.concat(await this.projectLeadService.projectLeadList(this.room.projectId, this.room)));
			this.log.info(`ProjectId is defined in this room, list of room project leads: ${projectLeadList}`);
		} else {
			this.log.info(`Process project leads with: ${projectLeadList}`);
		}


		if (projectLeadList.length && (this.room.projectLead === undefined || (this.room.projectLead !== undefined && this.room.projectLead))) {
			const processJoinedMembers = async (mxid: string) => {
    
				if (!mxid.includes(this.matrixDomain)) {
					this.log.warn(`No sync for federated users: ${mxid}`);
					return;
				}
    
				const member = joinedMembers[mxid];
				const userInfo = await this.synapseUserAPI.userInfo(mxid);
				const isProjectLead = projectLeadList.includes(userInfo.getEmail())
				this.log.info(member.display_name + ' - ' + mxid + ' - ' + userInfo.getEmail() + ' - project lead: ' + isProjectLead);
    
				// exclude admin
				if (userInfo.isAdmin())
					return;
    
				if (userInfo.getEmail() == '') {
					this.log.warn(`No email found for user ${member.display_name}`)
					return;
				}
    
				// only project lead user
				if (isProjectLead) {
					mxids = { ...mxids, ...this.setUserDefinitionValues(mxid) };
				}
			};
    
			await Promise.all(Object.keys(joinedMembers).map(processJoinedMembers));
		} else {
			this.log.warn('No project leads to process')
		}
		return mxids;
	}
    
	/**
     * Create a list of join room users which are defined in configuration
     * @param joinedMembers list of all join room member
     * @returns list of all mxid with powerlevel associate to user definition
     */
	async processRoomUsersFromConfiguration(roomId: string, joinedMembers: IJoinedMembers): Promise<userConfig> {
    
		// flatten array specially for yaml syntax
		//users:
		// - *defaultUsers
		// - '@usertest1'
		const roomUsers = this.room.users ? (Array.isArray(this.room.users) ? this.room.users : [this.room.users]) : [];
		roomUsers.push(this.defaultConfig.users);
		const roomsIncludeUsers = this.deleteDuplicateUsers(roomUsers.flat().map(this.setUserDefinitionValues));
    
		let mxids: userConfig = {};
    
		const processJoinedMembers = async (mxid: string) => {
			const roomUserDefine = this.findMxId(roomsIncludeUsers, mxid);
			if (roomUserDefine) {
				// remove mxid from original list to check if user really exist in room
				const index = roomsIncludeUsers.indexOf(roomUserDefine);
				roomsIncludeUsers.splice(index, 1);
    
				this.log.info(`Room Users Configuration find user: ${Object.keys(roomUserDefine)[0]}`);
				mxids = { ...mxids, ...roomUserDefine };
			}
		};
    
		await Promise.all(Object.keys(joinedMembers).map(processJoinedMembers));
    
		if (roomsIncludeUsers.length) {
			this.log.warn(`Users from Configuration file not present in room: ${roomsIncludeUsers.map(user => Object.keys(user)[0])}`);
			await Promise.all(roomsIncludeUsers.map(
				async (user) => {
					const userId = Object.keys(user)[0];
					try {
						const inviteResponse = await this.client.invite(roomId, userId);
						this.log.info(`Invite user ${userId} to room ${this.room.alias}:`, inviteResponse);
					} catch (e) {
						this.log.error(`Invite user ${userId} to room ${this.room.alias}`, e);
					}
				}
			));
		}
		return mxids;
	}
    
    
	findMxId(users: userConfig[], match: string): userConfig | null {
		for (const user of users) {
			const userKey = Object.keys(user)[0];
			if (userKey === match) {
				return user;
			}
		}
		return null;
	}
    
	setUserDefinitionValues(userDefinition: UserConfigDefinition): userConfig {
		const userMxId: string = (typeof userDefinition == 'string') ?
			userDefinition : Object.keys(userDefinition)[0];
		const powerLevel = (typeof userDefinition == 'string') ?
			this.defaultConfig.userPowerLevel : Object.values(userDefinition)[0] || this.defaultConfig.userPowerLevel;
		return { [MatrixUtils.getMxIdFormat(userMxId)]: powerLevel }
	}
    
	deleteDuplicateUsers(users: userConfig[]): userConfig[] {
		const returnUsers = [];
		const findUsers: string[] = [];
    
		for (const user of users) {
			const userKey = JSON.stringify(user);
			if (!findUsers.includes(userKey)) {
				returnUsers.push(user);
				findUsers.push(userKey);
			}
		}    
		return returnUsers;
	}
    
	async processPowerLevel(roomId: string, roomAlias: string, mxids: userConfig) {
		if (Object.keys(mxids).length === 0) {
			this.log.info('processPowerLevel: No users find to apply power level!');
			return
		}
		const listMxids = Object.keys(mxids).map(key => `${key}:${mxids[key]}`).join(', ');
		this.log.info(`processPowerLevel on users: ${listMxids}`);
    
		await this.roomService.setPowerLevel(roomId, roomAlias, mxids, this.defaultConfig.roomPowerLevel, this.defaultConfig.userPowerLevel).then((response: ISendEventResponse) => {
			this.log.info(`Moderator power level set for this room, see event_id: ${response.event_id}!`);
		}).catch((err) => {
			this.log.error('Error setting moderator power level in room \n', err);
		});
	}
}