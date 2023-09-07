// SPDX-FileCopyrightText: 2023 eclipse foundation
// SPDX-License-Identifier: EPL-2.0

import { Logger } from 'sitka';

/**
 * Simple wrapper around config
 */
export default class Config{

	log: Logger = Logger.getLogger({ name: this.constructor.name });

	protected config: any;

	constructor(configObj: unknown) {
		this.config = configObj;
	}

	setConfigObj(configObj: unknown) {
		this.config = configObj;
	}

	get(property: string): any {
		return this.config.get(property);
	}

	getBoolean(property: string): any {
		return bool(this.config.get(property));
	}

	getOrDefault(property: string, defaultValue: unknown): any {
		try {
			return this.get(property);
		} catch (error) {
			this.log.warn('PROPERTY NOT DEFINED :', property, ', DEFAULT VALUE APPLY :', defaultValue);
			return defaultValue;
		}
	}


}

function bool(v: any) { return v === 'false' ? false : !!v; }