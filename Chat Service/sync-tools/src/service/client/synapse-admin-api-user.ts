
// SPDX-FileCopyrightText: 2023 eclipse foundation
// SPDX-License-Identifier: EPL-2.0

import { Logger } from 'sitka';

const utils = require('matrix-js-sdk/lib/utils');
import { MatrixClient, Method } from 'matrix-js-sdk';
import SynapseUser, { ISynapseUser } from '../../entity/synapse-user';
import { SimpleCache } from '../../utils/simple-cache';


export default class SynapseAdminApiUser {

    log: Logger;

    client:MatrixClient;

    userCache: SimpleCache<string, SynapseUser>;

    constructor(matrixClient:MatrixClient, logCtx: string){
        this.client = matrixClient;
        this.userCache = new SimpleCache<string, SynapseUser>(); 

        this.log = Logger.getLogger(`${logCtx}/SynapseAdminApiUser`);
    }

    async userInfo(mxId:string): Promise<SynapseUser> {
        const cachedUser = this.userCache.get(mxId);
        if (cachedUser) {
            this.log.info(`Retrieving user info from cache: ${mxId}`);
            return Promise.resolve(cachedUser);
        }

        const path = utils.encodeUri("/_synapse/admin/v2/users/$mxId", { $mxId: mxId });
        this.log.info(`Call user info API: ${path}`);

        return this.client.http.authedRequest<ISynapseUser>(Method.Get, path, undefined, undefined, { prefix: '' })
            .then((user) => {
                const synapseUser = new SynapseUser(user);
                this.userCache.set(mxId, synapseUser);
                return synapseUser;
            });
    }
}