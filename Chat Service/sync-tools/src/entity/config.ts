// SPDX-FileCopyrightText: 2023 eclipse foundation
// SPDX-License-Identifier: EPL-2.0

import { Preset, Visibility } from 'matrix-js-sdk';


export interface IRoomPowerLevel {
    ban: number;
    events: Record<string, number>;
    events_default: number;
    historical: number;
    invite: number;
    kick: number;
    redact: number;
    state_default: number;
    users_default: number;
}

export type userConfig = Record<string, number>

export type UserConfigDefinition = string | userConfig | string[] | userConfig[]

export interface IDefaultConfig {
    users: userConfig;
    defaultProjectSpace: string;
    userPowerLevel: number;
    roomPowerLevel: IRoomPowerLevel;
    roomVisibility: string;
    roomPreset: string
}


export interface IRoom {
    alias: string;
    extraAlias: string|string[];
    name: string;
    visibility: Visibility;
    topic: string;
    preset: Preset;
    powerLevel: IRoomPowerLevel
    type: 'room' | 'space';
    projectLead: boolean;
    projectId: string;
    users: UserConfigDefinition;
    parent: string;
    avatar: string;
    forceUpdate: string;
    encryption: boolean;
}


export type IProject = Record<string, {rooms: IRoom[], projectLead: boolean}>

export interface IConfig {
    default: IDefaultConfig;
    projects: IProject[];
}
