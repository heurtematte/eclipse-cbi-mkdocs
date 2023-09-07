// SPDX-FileCopyrightText: 2023 eclipse foundation
// SPDX-License-Identifier: EPL-2.0

import { Logger } from 'sitka';

const log: Logger = Logger.getLogger('SchemaValidator');

import Ajv from 'ajv';
const ajv = new Ajv();

import schema from './schema.json';

export class SchemaValidator {
	public static validate(data: any): boolean {
		try {
			const validate = ajv.compile(schema);

			if (validate(data)) {
				return true; 
			} else {
				log.error('Errors :', validate.errors);
				return false; 
			}
		} catch (error) {
			log.error(error);
			return false;
		}
	}
}
