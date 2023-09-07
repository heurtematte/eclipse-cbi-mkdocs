// SPDX-FileCopyrightText: 2023 eclipse foundation
// SPDX-License-Identifier: EPL-2.0

import { Logger } from "sitka";
import { IProject, IRoom } from "../../entity/config";
import EclipseApiProject from "../client/eclipse-api-project";
import EclipseApiUser from "../client/eclipse-api-user";



export class ProjectLeadService{

    log: Logger;

	projectAPI: EclipseApiProject;
	userAPI: EclipseApiUser;

    constructor(eclipseAPIConfiguration:any, logCtx: string) {

        this.log = Logger.getLogger(`${logCtx}/ProjectLeadService`);

		this.projectAPI = new EclipseApiProject(eclipseAPIConfiguration.projectAPIBaseUrl);
		this.userAPI = new EclipseApiUser(eclipseAPIConfiguration.oauth, eclipseAPIConfiguration.additionnalOauth, eclipseAPIConfiguration.userAPIBaseUrl);
	}

    async projectLeadList(projectId:string , entity: IProject|IRoom) : Promise<string[]>{
        let plUsersEmails: string[] = [];
		const searchProjectLead = entity.projectLead;
		if (searchProjectLead === undefined || searchProjectLead) {
			const projectInfo = await this.projectAPI.getByProjectId(projectId);
			if (projectInfo) {
				this.log.info(`Project lead for ${projectId}: `, projectInfo?.project_leads.map(user => `${user.full_name} (${user.username})`).join(', '));

				plUsersEmails = await this.getProjectLeadUsersEmailInfosList(projectInfo);
				this.log.info(`Project lead user mail list: ${plUsersEmails}`);
			} else {
				this.log.warn(`Project ${projectId} is not an eclipse project, no project leads to sync`);
			}
		}
		return plUsersEmails;
	}

    /**
     * Get all project lead users information from a project object (API call) that hold a list of project lead
     * @param projectInfo result from API call: projectAPI.getBythis.projectId(this.projectId)
     * @param this.log  specific log
     * @returns list of project lead users
     */
	async getProjectLeadUsersEmailInfosList(projectInfo: EclipseProject | null): Promise<string[]> {
		let plUsersEmail: string[] = [];
    
		if (!projectInfo?.project_leads || projectInfo.project_leads.length === 0) {
			this.log.warn(`${projectInfo?.name} has no project leads!`);
			return plUsersEmail;
		}
    
		const users = await Promise.all(projectInfo.project_leads.map((plInfo) => this.userAPI.getByUsername(plInfo.username))).catch(error => { this.log.error(error) });
		plUsersEmail = users?.map((user: any) => user.mail) || [];
    
		return plUsersEmail;
	}
}