// SPDX-FileCopyrightText: 2023 eclipse foundation
// SPDX-License-Identifier: EPL-2.0

import EclipseApiClient, { ApiResponse } from "./eclipse-api-client";

import { Logger } from 'sitka';


export default class EclipseApiProject {

    log: Logger = Logger.getLogger({ name: this.constructor.name });;
    api: EclipseApiClient;
    path: string;

    constructor(baseUrl: string = 'https://projects.eclipse.org',
        path: string = '/api/projects', token: string = '', timeout = 20000) {

        this.api = new EclipseApiClient(baseUrl, token, timeout);
        this.path = path;

        this.api.axios.interceptors.response.use((response: ApiResponse<EclipseProject[]>) => {
            const project = response.data;
            return project;
        });
    }

    async getByProjectId(projectId: string): Promise<EclipseProject | null> {
        this.log.debug(`getByProjectId - projectId:${projectId}`);
        return this.api.axios.get(`${this.path}/${projectId}.json`).then((projects: EclipseProject[]) => projects[0]);
    }

    // async getByUsername(username: string): Promise<EclipseUser | null> {

    //     this.logger.debug(`EclipseApiUser:getByUsername(username = ${username})`);

    //     return await axios
    //       .get('https://api.eclipse.org/account/profile/' + username, await this.getAuthenticationHeaders())
    //       .then(result => result.data)
    //       .catch(err => {
    //         this.logger.error(`${err}`);
    //         return null;
    //       });
    //   }


}
