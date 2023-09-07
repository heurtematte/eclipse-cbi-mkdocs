// SPDX-FileCopyrightText: 2023 eclipse foundation
// SPDX-License-Identifier: EPL-2.0

import { Logger } from 'sitka';

const logger: Logger = Logger.getLogger('CONSOLE');

console.log = (...args: any[]) => {
	logger.info(args);
};

console.warn = (...args: any[]) => {
	logger.warn(args);
};

console.error = (...args: any[]) => {
	logger.error(args);
};