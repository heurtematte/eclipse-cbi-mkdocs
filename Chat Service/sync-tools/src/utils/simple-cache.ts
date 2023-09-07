// SPDX-FileCopyrightText: 2023 eclipse foundation
// SPDX-License-Identifier: EPL-2.0

export class SimpleCache<TKey, TValue> {
	private cache: { [key: string]: TValue } = {};
  
	set(key: TKey, value: TValue): void {
		const cacheKey = this.getCacheKey(key);
		this.cache[cacheKey] = value;
	}
  
	get(key: TKey): TValue | undefined {
		const cacheKey = this.getCacheKey(key);
		return this.cache[cacheKey];
	}
  
	has(key: TKey): boolean {
		const cacheKey = this.getCacheKey(key);
		return cacheKey in this.cache;
	}
  
	remove(key: TKey): void {
		const cacheKey = this.getCacheKey(key);
		delete this.cache[cacheKey];
	}
  
	clear(): void {
		this.cache = {};
	}
  
	private getCacheKey(key: TKey): string {
		return JSON.stringify(key);
	}
}