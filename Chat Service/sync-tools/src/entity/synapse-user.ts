// SPDX-FileCopyrightText: 2023 eclipse foundation
// SPDX-License-Identifier: EPL-2.0

interface ThreePid {
	medium: string;
	address: string;
	validated_at: number;
	added_at: number;
}

interface ExternalId {
	auth_provider: string;
	external_id: string;
}

export interface ISynapseUser {
	name: string;
	is_guest: number;
	admin: boolean;
	consent_version: string;
	consent_ts: number;
	consent_server_notice_sent: any;
	appservice_id: any;
	creation_ts: number;
	user_type: any;
	deactivated: boolean;
	shadow_banned: boolean;
	displayname: string;
	avatar_url: string;
	threepids: ThreePid[];
	external_ids: ExternalId[];
	erased: boolean;
}

export default class SynapseUser {
	private readonly synapseUser: ISynapseUser;

	constructor(synapseUser: ISynapseUser) {
		this.synapseUser = synapseUser;
	}

	getName(): string {
		return this.synapseUser.name;
	}

	isGuest(): boolean {
		return this.synapseUser.is_guest === 1;
	}

	isAdmin(): boolean {
		return this.synapseUser.admin;
	}

	getConsentVersion(): string {
		return this.synapseUser.consent_version;
	}

	getConsentTimestamp(): Date {
		return new Date(this.synapseUser.consent_ts);
	}

	isDeactivated(): boolean {
		return this.synapseUser.deactivated;
	}

	isShadowBanned(): boolean {
		return this.synapseUser.shadow_banned;
	}

	getDisplayName(): string {
		return this.synapseUser.displayname;
	}

	getAvatarUrl(): string {
		return this.synapseUser.avatar_url;
	}

	getEmail(): string {
		if (this.synapseUser.threepids.length > 0) {
			const emailThreepid = this.synapseUser.threepids.find(threepid => threepid.medium === 'email');
			if (emailThreepid) {
				return emailThreepid.address;
			}
		}
		return '';
	}
}
