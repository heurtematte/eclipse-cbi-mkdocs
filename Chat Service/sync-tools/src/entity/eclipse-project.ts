// SPDX-FileCopyrightText: 2023 eclipse foundation
// SPDX-License-Identifier: EPL-2.0

interface IRepo {
	url: string;
	source_branch: string;
	checkout_dir: string;
}

interface IContributor {
	username: string;
	full_name: string;
	url: string;
}

type ICommiters = IContributor

type IProjectLeads = IContributor

class EclipseProject {
	project_id: string;
	short_project_id: string;
	name: string;
	summary: string;
	description: string;
	url: string;
	website_url: string;
	website_repo: IRepo[];
	logo: string;
	tags: string[];
	github_repos: IRepo[];
	github: {
		org: string;
		ignored_repos: string[];
	};
	gitlab_repos: IRepo[];
	gitlab: {
		project_group: string;
		ignored_sub_groups: string[];
	};
	gerrit_repos: IRepo[];
	contributors: IContributor[];
	committers: ICommiters[];
	project_leads: IProjectLeads[];

	constructor(data: EclipseProject) {
		this.project_id = data.project_id;
		this.short_project_id = data.short_project_id;
		this.name = data.name;
		this.summary = data.summary;
		this.description = data.description;
		this.url = data.url;
		this.website_url = data.website_url;
		this.website_repo = data.website_repo;
		this.logo = data.logo;
		this.tags = data.tags;
		this.github_repos = data.github_repos;
		this.github = data.github;
		this.gitlab_repos = data.gitlab_repos;
		this.gitlab = data.gitlab;
		this.gerrit_repos = data.gerrit_repos;
		this.contributors = data.contributors;
		this.committers = data.committers;
		this.project_leads = data.project_leads;
	}
}
