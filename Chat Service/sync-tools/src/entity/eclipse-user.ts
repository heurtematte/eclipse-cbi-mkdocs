// SPDX-FileCopyrightText: 2023 eclipse foundation
// SPDX-License-Identifier: EPL-2.0

interface Country {
    code: string;
    name: string;
}

interface ECA {
    signed: boolean;
}

interface Friends {
    friend_id: number;
}

export default class EclipseUser {
	uid: number;
	name: string;
	mail: string;
	eca: ECA;
	is_committer: boolean;
	friends: Friends;
	first_name: string;
	last_name: string;
	twitter_handle: string;
	org: string;
	job_title: string;
	website: string;
	country: Country;
	bio: string;
	interests: string[];

	constructor(data: any) {
		this.uid = data.uid;
		this.name = data.name;
		this.mail = data.mail;
		this.eca = data.eca;
		this.is_committer = data.is_committer;
		this.friends = data.friends;
		this.first_name = data.first_name;
		this.last_name = data.last_name;
		this.twitter_handle = data.twitter_handle;
		this.org = data.org;
		this.job_title = data.job_title;
		this.website = data.website;
		this.country = data.country;
		this.bio = data.bio;
		this.interests = data.interests;
	}
}