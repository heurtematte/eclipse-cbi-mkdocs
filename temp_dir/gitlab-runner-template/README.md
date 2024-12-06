<!--
SPDX-FileCopyrightText: 2024 eclipse foundation
SPDX-License-Identifier: EPL-2.0
-->

# GitLab CI templates

`gitlab-ci-templates` is a repository of GitLab CI template jobs and pipelines that aims to help Eclipse Foundation Open Sources projects get started quickly in the Eclipse Infrastructure OKD and with all features provided by GitLab.

[[_TOC_]]

## Getting started!

Create a `.gitlab-ci.yml` file in your project root directory. 

ex: 

```yaml
include:
  - project: 'eclipsefdn/it/releng/gitlab-runner-service/gitlab-ci-templates'
    file: pipeline.gitlab-ci.yml'

```

And push to the GitLab repository.

NOTE: You must first activate `CI/CD` feature in your project.
`Settings` -> `General`, select section `Visibility, project features, permissions`, Check `CI/CD`, and Save.

## Template job lists

| Job        | Description  | 
|-------------|--------------|
| `workflow`  | Define a workflow for your pipeline |
| `dco`  | [DCO check tool](https://github.com/christophebedard/dco-check) that certify that a contributor has the right to submit their code according to the Developer Certificate of Origin ([DCO](https://developercertificate.org/))  |
| `hadolint`  | Control docker image quality with [hadolint](https://github.com/hadolint/hadolint) tool  |
| `reuse`  | Check [REUSE](https://reuse.software/) compliance  |
| `buildkit`  | Build docker image with [buildkit](https://github.com/moby/buildkit) and [crane](https://github.com/google/go-containerregistry/blob/main/cmd/crane/doc/crane.md) tools and specific instance dedicated in EF infrastructure (SERVICE_ADDRESS)  |
| `eca`  | Check [Eclipse Contributor Agreement](https://www.eclipse.org/legal/ECA.php)  from commits in Merge Request |
| `ssh`  | Configure ssh client in a `before_script` section |
| `git`  | Configure git client in a `before_script` section |
| `download-eclipse.org`  | Push artifacts to `download.eclipse.org` just override `script` section  |
| `repo-eclipse-org`  | Push artifacts to `repo.eclipse.org` just override `script` section  |
| `renovate`  | Automated dependency updates. [Renovate](https://github.com/renovatebot/renovate)  |
| `matrix`  | Get credentials for matrix bot  |

## Template auth job lists

| Job        | Description  |  Inherit |
|-------------|--------------|--------------|
| `ef-buildkit`  | Configure buildkit client with `docker.com` credentials | `ef-buildkit-docker.com` |
| `ef-buildkit-docker.com`  | Configure buildkit client with `docker.com` credentials | `buildkit` |
| `ef-buildkit-quay.com`  | Configure buildkit client with `quay.io` credentials | `buildkit` |
| `ef-git`  | Configure git client with gitlab credentials | `ef-git-gitlab` |
| `ef-git-gitlab`  | Configure git client with gitlab credentials | `git` |
| `ef-git-github`  | Configure git client with github credentials | `git` |
| `ef-download-eclipse.org`  | Configure job with `projects-storage` credentials  | `download-eclipse.org` |
| `ef-repo-eclipse-org`  | Configure job with `repo.eclipse.org` credentials   | `repo-eclipse-org`  |
| `ef-build-develocity`  | Configure job with `develocity.eclipse.org` credentials   | `ef-build-develocity`  |
| `ef-build-develocity-maven`  | Configure job with `develocity.eclipse.org` credentials and build with maven  | `ef-build-develocity`  |
| `ef-build-develocity-gradle`  | Configure job with `develocity.eclipse.org` credentials and build with gradle  | `ef-build-develocity`  |
| `ef-renovate`  | Configure job with `renovate` credentials   |   |

### How to include a template job in your pipeline

```yaml
include:
  - project: 'eclipsefdn/it/releng/gitlab-runner-service/gitlab-ci-templates'
    file: '/jobs/dco.gitlab-ci.yml'

stages:
  - compliance
```

### EF specific variables 

These variables are injected at runner creation:
* `EF_PROJECT_ID`
* `EF_SHORT_NAME`
  
e.g: with [eclipse cbi project](https://projects.eclipse.org/projects/technology.cbi)
* EF_PROJECT_ID=`techonology.cbi`
* EF_SHORT_NAME=`cbi`

`EF_PROJECT_ID` can be used in the path when using secrets from the `secretsmanager`. 


## Secrets manager

GitLab CI can use the internal secrets manager to fetch secrets for publishing docker images, accessing internal services, ...

e.g:

```yaml
  secrets:
    REPO_USERNAME:
      vault: $EF_PROJECT_ID/repo.eclipse.org/username@cbi
      file: false
    REPO_PASSWORD:
      vault: $EF_PROJECT_ID/repo.eclipse.org/password@cbi
      file: false
```

NOTE: If you are not sure of the path, don't hesitate to ask a support

### Build Docker image with buildkit

Buildkit job needs `CI_REGISTRY_IMAGE` variable definition.

CI Auth variables must be set a least in project CI/CD variable configuration with a mask or in a vault: 
* `CI_REGISTRY_USER`: docker registry username
* `CI_REGISTRY_PASSWORD`: docker registry token

The registry by default is `docker.io`, but can be overriden with `CI_REGISTRY`.

```yaml
include:
  - project: 'eclipsefdn/it/releng/gitlab-runner-service/gitlab-ci-templates'
    file: '/jobs/buildkit.gitlab-ci.yml'

variables:  
  CI_REGISTRY_IMAGE: docker.io/eclipsecbi/gitlab-ci-templates
```

Full example with secrets:

e.g: 

```yaml
include:
  - project: 'eclipsefdn/it/releng/gitlab-runner-service/gitlab-ci-templates'
    file: '/jobs/buildkit.gitlab-ci.yml'

variables:
  CI_REGISTRY_IMAGE: docker.io/eclipsecbi/gitlab-ci-templates

buildkit:
  secrets:
    CI_REGISTRY_USER:
      vault: $EF_PROJECT_ID/docker.com/username@cbi
      file: false
    CI_REGISTRY_PASSWORD:
      vault: $EF_PROJECT_ID/docker.com/api-token@cbi
      file: false
```

IMPORTANT: Buildkit needs a build docker image infrastructure, address of this infrastructure can be changed with `BUILDKIT_ADDRESS`. 

### Publish to projects-storage (download.eclipse.org)

Replace the script section based on what needs to be copied to the Project Storage server.

```yaml
include:
  - project: 'eclipsefdn/it/releng/gitlab-runner-service/gitlab-ci-templates'
    file: '/jobs/projects-storage.gitlab-ci.yml'

projects-storage:
  extends: .projects-storage
  stage: deploy
  secrets:
    SSH_PRIVATE_KEY:
      vault: $EF_PROJECT_ID/projects-storage.eclipse.org/id_rsa@cbi
    SSH_PRIVATE_KEY_PASSPHRASE:
      vault: $EF_PROJECT_ID/projects-storage.eclipse.org/id_rsa.passphrase@cbi
  script:
    - echo "Copy your artifacts with ssh."
    - ssh "genie.$EF_SHORT_NAME@$SSH_HOSTNAME" ls -l "$DOWNLOADS_PATH"
```

## Pipeline lists

### Pipeline compliance

Pipeline compliance groups all compliance jobs in one include file.

```yaml
include:
  - project: 'eclipsefdn/it/releng/gitlab-runner-service/gitlab-ci-templates'
    file: pipeline-compliance.gitlab-ci.yml'
```

### Pipeline autodevops

Pipeline `autodevops` includes only features from GitLab working in the Eclipse Foundation Infrastructure.

```yaml
include:
  - project: 'eclipsefdn/it/releng/gitlab-runner-service/gitlab-ci-templates'
    file: pipeline-autodevops.gitlab-ci.yml'
```

These are all `autodevops` features included:

```yaml
  - template: Jobs/Container-Scanning.gitlab-ci.yml  # https://gitlab.com/gitlab-org/gitlab/blob/master/lib/gitlab/ci/templates/Jobs/Container-Scanning.gitlab-ci.yml
  - template: Jobs/SAST.gitlab-ci.yml # https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/SAST-IaC.gitlab-ci.yml
  - template: Jobs/SAST-IaC.latest.gitlab-ci.yml # https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/SAST-IaC.gitlab-ci.yml
  - template: Jobs/Secret-Detection.gitlab-ci.yml  # https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/Secret-Detection.gitlab-ci.yml
  - template: Jobs/Dependency-Scanning.gitlab-ci.yml  # https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/Dependency-Scanning.gitlab-ci.yml
```

The following features are not supported yet due to Openshift security policies:
* Auto Code Quality
* Auto License Compliance (License scanning of CycloneDX files is supported on OpenShift)
* Auto Browser Performance Testing
* Auto Build
* Operational Container Scanning (Note: Pipeline Container Scanning is supported)
  

### Pipeline container

Pipeline container groups all related container tools jobs in one file, including:
* `buildkit` job
* `hadolint` job
* `autodevops` pipeline

```yaml
include:
  - project: 'eclipsefdn/it/releng/gitlab-runner-service/gitlab-ci-templates'
    file: pipeline-container.gitlab-ci.yml'
```


### Pipeline "Full"

This pipeline includes previous pipelines (`pipeline-compliance`, `pipeline-autodevops`), and adds container build feature and hadolint tool analysis. 


```yaml
include:
  - project: 'eclipsefdn/it/releng/gitlab-runner-service/gitlab-ci-templates'
    file: pipeline.gitlab-ci.yml'

variables:  
  CI_REGISTRY_IMAGE: docker.io/eclipsecbi/gitlab-ci-templates
```

IMPORTANT: `CI_REGISTRY_IMAGE`, docker registry auth variables are mandatory on this pipeline.

## Workflow

Default workflow provided is as follows:

```yaml
workflow:
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event" || $CI_PIPELINE_SOURCE == "web" || $CI_PIPELINE_SOURCE == "parent_pipeline"
    - if: $CI_MERGE_REQUEST_IID
    - if: $CI_COMMIT_TAG
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
```

This one can be easily overriden in `.gitlab-ci.yml` project file.

## Quick tips!

### How to disable a specific job? 

```yaml
buildkit:
  rules:
    - when: never
```

### How to allow a job to fail and not the pipeline?

```yaml
dco:
  allow_failure: true
```

### How to target a docker file in a directory?

```yaml
buildkit:
  variables:
    BUILD_CONTEXT: test/docker
    BUILD_CONTEXT_CHANGE: test/docker

hadolint:
  variables:
    DOCKERFILE_CONTEXT: test/docker
    DOCKERFILE_CONTEXT_CHANGE: test/docker
```

### How to only build docker image with latest tag?

```yaml
buildkit:
  variables:
    IMAGE_TAG: latest
```

### How to apply my own tag strategy for docker image?

By default, the buildkit job proposes a tagging strategy for docker image, but this one can be overriden in `before_script` section by project.

```yaml
buildkit:
  before_script:
    - echo 'define your tag stategy'
```

WARNING: if you use `autodevops` you must apply this new strategy to Container Scanning

```yaml
container_scanning:
  variables: 
    GIT_STRATEGY: fetch
    BUILD_CONTEXT_CHANGE: "" # https://gitlab.com/gitlab-org/gitlab/-/issues/216906
  before_script:
    - echo 'define your tag stategy'
    - export CS_REGISTRY_USER=$CI_REGISTRY_USER
    - export CS_REGISTRY_PASSWORD=$CI_REGISTRY_PASSWORD
    - export CS_IMAGE="$CI_REGISTRY_IMAGE${CONTAINER_NAME:+"/$CONTAINER_NAME"}":"$IMAGE_TAG"
```

## Other use cases

### Maven integration with `repo.eclipse.org`

Configure `distributionManagement` in the `pom.xml`.

```xml
  ...  
  <distributionManagement>
    <repository>
      <id>repo.eclipse.org</id>
      <name>Project Repository - Releases</name>
      <url>https://repo.eclipse.org/content/repositories/project-releases/</url>
    </repository>
    <snapshotRepository>
      <id>repo.eclipse.org</id>
      <name>Project Repository - Snapshots</name>
      <url>https://repo.eclipse.org/content/repositories/project-snapshots/</url>
    </snapshotRepository>
  </distributionManagement>
  ....
```

Create `settings.xml` file in your project with this configuration.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<settings>
  <interactiveMode>false</interactiveMode>
  <servers>
    <server>
      <id>repo.eclipse.org</id>
      <username>${env.REPO_USERNAME}</username>
      <password>${env.REPO_PASSWORD}</password>
    </server>
  </servers>
  <mirrors>
    <mirror>
      <id>eclipse.maven.central.mirror</id>
      <name>Eclipse Central Proxy</name>
      <url>https://repo.eclipse.org/content/repositories/maven_central/</url>
      <mirrorOf>central</mirrorOf>
    </mirror>
  </mirrors>
</settings>
```

Job example to deploy to `repo.eclipse.org`: 

```yaml
repo.eclipse.org:
  stage: deploy
  image: maven:3.9.6-eclipse-temurin-21
  secrets:
    REPO_USERNAME:
      vault: <project_id>/repo.eclipse.org/username@cbi
      file: false
    REPO_PASSWORD:
      vault: <project_id>/repo.eclipse.org/password@cbi
      file: false
  variables:
    MAVEN_OPTS: "-Dhttps.protocols=TLSv1.2 -Dmaven.repo.local=$CI_PROJECT_DIR/.m2/repository -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=WARN -Dorg.slf4j.simpleLogger.showDateTime=true -Djava.awt.headless=true"
    MAVEN_CLI_OPTS: "--batch-mode --errors --fail-at-end --show-version -DinstallAtEnd=true -DdeployAtEnd=true"
  script:
    - mvn $MAVEN_CLI_OPTS deploy -s settings.xml
```

### Gitlab Services Integration

For security reasons, most official images from dockerhub don't work with the foundation's okd cluster.
Which is the case with the `postgresql` docker image. But alternatives exist. 

Do not hesitate to ask for support in such cases.

```yaml
variables:  
  POSTGRESQL_DATABASE: smo
  POSTGRESQL_USER: custom_user
  POSTGRESQL_PASSWORD: custom_pass

gitlab-services-integration:
  stage: integration
  needs: []
  services:
    - name: quay.io/sclorg/postgresql-15-c9s
      alias: Postgres
  image: Postgres
  script:
    - export PGPASSWORD=$POSTGRES_PASSWORD
    - psql -h "postgres" -U "$POSTGRESQL_USER" -d "$POSTGRESQL_DATABASE" -c "SELECT 'OK' AS status;"
```

NOTE: Variables to pass to the services have to be defined at the pipeline level.