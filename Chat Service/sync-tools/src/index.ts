// SPDX-FileCopyrightText: 2023 eclipse foundation
// SPDX-License-Identifier: EPL-2.0

import { Logger } from 'sitka';
import ConfigManager from './service/configManager';
import * as sdk from "matrix-js-sdk";
import { MemoryStore } from 'matrix-js-sdk';
import Config from './utils/config';
import { EventEmitter } from 'node:events';
import { IProject } from './entity/config';
import { ProjectProcess } from './business/project-process';
import { SchemaValidator } from './utils/schema-validator';

import "./utils/sitka-console";

EventEmitter.defaultMaxListeners = 30;

const log = Logger.getLogger("index");

const config = new Config(require("config"));

const eclipseAPIConfiguration = config.get('eclipseAPI');

let matrixAPIConfig = { ...config.get('matrixAPI'), store: new MemoryStore() };

const matrixClient = sdk.createClient(matrixAPIConfig);

const matrixDomain = config.getOrDefault('matrixAPI.matrixDomain', config.get('matrixAPI.baseUrl').replace(/^https?:\/\//i, ""));

log.info(`######################### START Chat Service SYNC #########################`);

log.info(`Start sync on matrix server: ${config.get('matrixAPI.baseUrl')}`);

const dry = config.getBoolean('dry');
log.info(`MODE DRY: ${dry}`);

const configFile = config.getOrDefault('projectConfigFile', __dirname + `/../config/project.yaml`);

log.info(`LOAD CONFIGURATION: ${configFile}`);

const configManager = new ConfigManager(configFile);

log.info(`VALIDATE CONFIGURATION`);
if (SchemaValidator.validate(configManager.getConfiguration())) {
	log.info('Project Configuration is valide.');
} else {
	log.error('Project Configuration is invalide!');
	process.exit(1);
}

const defaultConfig = configManager.getDefaultConfiguration();
const projectConfig = configManager.getProjectsConfiguration();

log.info(`DEFAULT CONFIGURATION: `, defaultConfig);
log.info(`PROJECTS CONFIGURATION: `, JSON.stringify(projectConfig, null, 4));

(async () => {

	let promisesProjects: any[] = [];
	projectConfig?.forEach(async (project: IProject) => {
		const projectProcess = new ProjectProcess(eclipseAPIConfiguration, matrixClient, defaultConfig, matrixDomain, project , dry)
		promisesProjects.push(projectProcess.processEclipseProject());
	});

	await Promise.all(promisesProjects).then(() => {
		log.info('Process projects end!');
	}).catch(err => {
		console.error('Error while processing projects:', err);
	});

	log.info("######################### END Chat Service SYNC #########################");
})()

