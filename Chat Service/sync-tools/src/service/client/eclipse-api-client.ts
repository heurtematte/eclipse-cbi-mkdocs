// SPDX-FileCopyrightText: 2023 eclipse foundation
// SPDX-License-Identifier: EPL-2.0

import axios, { CreateAxiosDefaults } from 'axios';
const { ClientCredentials } = require('simple-oauth2');

import { Logger } from 'sitka';

export interface ApiResponse<T> {
    data: T;
}

export interface IAdditionnalOauth {
    timeout: number;
    scope: string;
}

export interface IOauth {
    client: {
        id: string,
        secret: string,
    },
    auth: {
        tokenHost: string,
        tokenPath: string,
        authorizePath: string
    }
}

const HOUR_IN_SECONDS = 3600;

export default class EclipseApiClient {

    log: Logger = Logger.getLogger({ name: this.constructor.name });;
    
    axios: any;

    client: any;
    accessToken: any;
    scope: string|undefined;
    oauthTimeout = HOUR_IN_SECONDS;

    constructor(baseUrlAPI: string = 'https://api.eclipse.org',
        tokenAPI: string = '', timeoutAPI = 20000, oauth?:IOauth, additionnalOauth?:IAdditionnalOauth) {

        const config: CreateAxiosDefaults = {
            baseURL: baseUrlAPI,
            timeout: timeoutAPI,
        }
        if (tokenAPI) {
            config.headers = {
                'Authorization: Bearer': tokenAPI
            };
        }
        this.axios = axios.create(config);

        this.scope = additionnalOauth?.scope;
        if (oauth) {
            this.client = new ClientCredentials(oauth);
            // this.accessToken = await this.client.getToken({
            //     scope: additionnalOauth?.scope,
            // });
        }
    }

    async getAccessToken() {
        if (this.accessToken === undefined || this.accessToken.expired(this.oauthTimeout)) {
            try {
                this.accessToken = await this.client.getToken({
                    scope: this.scope,
                });
            } catch (error) {
                this.log.error(error);
            }
            return this.accessToken.token.access_token;
        }
    }
}




