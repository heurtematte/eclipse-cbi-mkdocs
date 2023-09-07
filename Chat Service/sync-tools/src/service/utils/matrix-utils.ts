
// SPDX-FileCopyrightText: 2023 eclipse foundation
// SPDX-License-Identifier: EPL-2.0

import Config from "../../utils/config";


const config = new Config(require("config"));
const matrixDomain = config.getOrDefault('matrixAPI.matrixDomain', config.get('matrixAPI.baseUrl').replace(/^https?:\/\//i, ""));

export class MatrixUtils {

    static getMxIdFormat(userMxId:string){
        if (!userMxId.startsWith('@')) {
            userMxId = '@' + userMxId;
        }
        return userMxId.includes(':') ? userMxId : userMxId + ":" + matrixDomain;
    }

    static getRoomAliasFormat(roomAlias:string){
        if (!roomAlias.startsWith('#')) {
            roomAlias = '#' + roomAlias;
        }
        return roomAlias.includes(':') ? roomAlias : roomAlias + ":" + matrixDomain;
    }

    static getDomain(){
        return matrixDomain;
    }
}