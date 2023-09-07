// SPDX-FileCopyrightText: 2023 eclipse foundation
// SPDX-License-Identifier: EPL-2.0

import YAML from 'yaml';
import fs from 'fs';
import { IConfig, IDefaultConfig, IProject } from '../entity/config';

export default class ConfigManager {

	config: IConfig;

	constructor(configFile: string) {
		const file = fs.readFileSync(configFile, 'utf8')
		this.config = YAML.parse(file);
	}

	// getProjectRooms(projectName: string): IRoom[] {
	// 	const project = this.config.projects.find((project) => project[projectName]);
	// 	if (!project) {
	// 		throw new Error(`Project ${projectName} not found`);
	// 	}
	// 	return project[projectName].rooms;
	// }

	getConfiguration(): IConfig {
		return this.config;
	}

	getDefaultConfiguration(): IDefaultConfig {
		return this.config.default;
	}

	getProjectsConfiguration(): IProject[] {
		return this.config.projects;
	}
}