// SPDX-FileCopyrightText: 2023 eclipse foundation
// SPDX-License-Identifier: EPL-2.0

import { IDefaultConfig, IProject, IRoom } from '../entity/config';
import { RoomProcess } from './room-process';
import { Logger } from 'sitka';
import { MatrixClient } from 'matrix-js-sdk';
import { ProjectLeadService } from '../service/eclipse/project-lead-service';


export class ProjectProcess{

	log: Logger;

	client: MatrixClient;
	defaultConfig: IDefaultConfig;
	matrixDomain: string;
	dry: boolean;
	eclipseAPIConfiguration: any;

	projectId:string;
	project: IProject;

	projectLeadService:ProjectLeadService;


	constructor(eclipseAPIConfiguration:any, matrixClient: MatrixClient, defaultConfig: IDefaultConfig, matrixDomain: string, project: IProject , dry: boolean) {

		this.projectId = Object.keys(project)[0];
		this.project = project;
		this.client = matrixClient;
		this.defaultConfig = defaultConfig;
		this.matrixDomain = matrixDomain;
		this.dry = dry;
		this.eclipseAPIConfiguration = eclipseAPIConfiguration;

		this.log = Logger.getLogger(`${this.projectId}/ProjectProcess`);

		this.projectLeadService = new ProjectLeadService(eclipseAPIConfiguration, `${this.projectId}`);
	}

	async processEclipseProject() {
		const promisesRooms: Promise<void>[] = [];
		const promisesSpaces: Promise<void>[] = [];
		const plUsersEmails: string[] = await this.projectLeadService.projectLeadList(this.projectId, this.project);
		this.project[this.projectId].rooms.forEach(async (room: IRoom) => {
			const processMatrixRoom = new RoomProcess(this.eclipseAPIConfiguration, this.client, this.defaultConfig, this.matrixDomain, this.projectId, room, plUsersEmails, this.dry);
			(room.type == 'space' ? promisesSpaces : promisesRooms).push(processMatrixRoom.processMatrixRoom());
		});
    
		await this.processRoomPromises(promisesSpaces, 'space');
		await this.processRoomPromises(promisesRooms, 'room');
	}
    
	async processRoomPromises(roomPromises: Promise<void>[], type: string) {
		this.log.info(`Process ${type}...`);
		if (roomPromises.length == 0) {
			this.log.info(`No ${type} defined!`);
		} else {
			await Promise.all(roomPromises).then(() => {
				this.log.info(`Process ${type} end!`);
			}).catch(err => {
				console.error(`Error while processing ${type}:`, err);
			});
		}
	}

}
