// SPDX-FileCopyrightText: 2023 eclipse foundation
// SPDX-License-Identifier: EPL-2.0

import EclipseApiClient, { ApiResponse, IAdditionnalOauth, IOauth } from "./eclipse-api-client";

import { Logger } from 'sitka';
import EclipseUser from "../../entity/eclipse-user";

export default class EclipseApiUser {

    log: Logger = Logger.getLogger({ name: this.constructor.name });
    api: EclipseApiClient;
    path: string;

    constructor(oauth?:IOauth, additionnalOauth?:IAdditionnalOauth, baseUrl: string = 'https://api.eclipse.org',
        path: string = '/account/profile', token: string = '', timeout = 20000) {

        this.api = new EclipseApiClient(baseUrl, token, timeout, oauth, additionnalOauth);
        this.path = path;

        this.api.axios.interceptors.response.use((response: ApiResponse<EclipseUser>) => {
            const project = response.data;
            return project;
        });
    }

    async getByUsername(username: string): Promise<EclipseUser | null> {
        this.log.debug(`getByUsername - username:${username}`);
        return this.api.axios.get(`${this.path}/${username}`, {
          headers: {
            Authorization: `Bearer ${await this.api.getAccessToken()}`,
          },
        });
    }

}
