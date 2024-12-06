# GitLab Runner Service 

As a part of the Common Build Infrastructure (CBI), the GitLab Runner Service aims to assist Eclipse projects in enabling GitLab CI within their projects.

It allows the execution of GitLab CI pipelines through runners deployed in the secure and scalable Eclipse Foundation's Kubernetes infrastructure by allocating the necessary resources.

Projects hosted on `gitlab.eclipse.org` can now take advantage of this new service.

This service is powered by [GRAC! (GitLab Runner As Code)](https://gitlab.eclipse.org/eclipsefdn/it/releng/gitlab-runner-service/gitlab-runner-as-code), a tool developed by the foundation that enables rapid deployment of this service, simplifying configuration and maintenance.

IMPORTANT: The use of this service is currently not extendable to other GitLab instances like `gitlab.com`, which, beyond the installation and the use of runners, would require additional work from the Eclipse Foundation for managing Eclipse projects on gitlab.com, similar to what exists with GitHub.

[TOC]

## Introduction

### What is a GitLab runner?

A GitLab Runner is an agent that works with GitLab CI pipeline. It executes tasks (jobs) defined in your project `.gitlab-ci.yml` file, by automating various stages such as building, testing, and even deploying code. 

For more information, start with: https://docs.gitlab.com/ee/topics/build_your_application.html 

### Leverage GitLab runner configuration and maintenance with Grac!

The goal of GRAC! is to make the administration of GitLab runner instances on a Kubernetes based infrastructure bearable. It uses automation, templates and a configuration-as-code approach. GRAC! consist of a set of custom shell scripts and a jsonnet generation.

Following the implementation of Jenkins instance as code at Eclipse Foundation with JIRO, and over +250 instances in production, there is a demand from projects to extend this support to GitLab CI.

So as a natural extension, GRAC! is born. Under the woods: same approach and technologies.

Grac! helps reduce administration overhead for recurring tasks like setting up a new GitLab runner for groups/projects, configuration, allowing resources, handling specific requests, maintaining runners version, etc.

## Quick start!

### Request a runner

A runner can be requested by filling a ticket on the [helpdesk](https://gitlab.eclipse.org/eclipsefdn/helpdesk/-/issues/new). 
Please ensure your project lead has approved with a +1 the request. 

### First integration

Create your first `.gitlab-ci.yml` file in your project.

```yaml
default:
  tags:
    - origin:eclipse # allow to target eclipse runner

stages:
  - build  

my_build_job: 
  stage: build
  script:
    - echo "example job 1"
```

You can find many templates [here](https://docs.gitlab.com/ee/ci/examples/#cicd-templates)


## Provided Services

### Pipeline template: Basic features

The Eclipse Foundation provides a set of functionality to address needs related to control, construction, and publication. All of these functionalities are available within the [gitlab-ci-templates](https://gitlab.eclipse.org/eclipsefdn/it/releng/gitlab-runner-service/gitlab-ci-templates/), project, and can be imported into project pipelines.

Here is an overview of the features : 
* `Compliance`: use of libraries [REUSE](https://reuse.software/), [DCO check tool](https://github.com/christophebedard/dco-check), and an ECA script validation [Eclipse Contributor Agreement](https://www.eclipse.org/legal/ECA.php)
* `Container image build`: build Container image based on the BuildKit Eclipse Foundation infrastructure and publish to a registry like `Docker Hub`
* `Quality`: control dockerfile writing with [hadolint](https://github.com/hadolint/hadolint) tool

NOTE about [GitLab Auto DevOps](https://docs.gitlab.com/ee/topics/autodevops/)

### Pipeline template: Auto Devops

GitLab provides what's called `Auto DevOps` which is a comprehensive set of predefined CI/CD pipelines and settings, that aim to streamline and automate the software development lifecycle, from code creation to deployment and monitoring. Auto DevOps is designed to simplify the process by providing a preconfigured CI/CD setup.

This feature provides a time-saving advantage in terms of configuration and CI pipeline deployment. However, this mode is not entirely suited to the operational constraints of the Eclipse Foundation's infrastructure. That's why the foundation offers some of these functionalities with an equivalent ready-to-use pipeline for our infrastructure.

Available features: 
* [Container Scanning](https://gitlab.com/gitlab-org/gitlab/blob/master/lib/gitlab/ci/templates/Jobs/Container-Scanning.gitlab-ci.yml)
* [Sast Analysis](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/SAST-IaC.gitlab-ci.yml)
* [Sast IaC Analysis](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/SAST-IaC.gitlab-ci.yml)
* [Secret Detection](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/Secret-Detection.gitlab-ci.yml)
* [Dependency Scanning](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/Dependency-Scanning.gitlab-ci.yml)

All `Autodevops` features available in a specific pipeline [pipeline-autodevops.gitlab-ci.yml](https://gitlab.eclipse.org/eclipsefdn/it/releng/gitlab-runner-service/gitlab-ci-templates/-/blob/main/pipeline-autodevops.gitlab-ci.yml)

For more information, please read the documentation [here] (https://gitlab.eclipse.org/eclipsefdn/it/releng/gitlab-runner-service/gitlab-ci-templates/-/blob/main/README.md)

IMPORTANT: Known limitations
When using OpenShift to run a GitLab Runner Fleet, we do not support some GitLab features given OpenShift’s security model. Features requiring Docker-in-Docker might not work.

For Auto DevOps, the following features are not supported yet:
* Auto Code Quality
* Auto License Compliance (License scanning of CycloneDX files is supported on OpenShift)
* Auto Browser Performance Testing
* Auto Build
* Operational Container Scanning (Note: Pipeline Container Scanning is supported)
 
### Pipeline template: Full feature

We recommend using the full pipeline [pipeline.gitlab-ci.yml](https://gitlab.eclipse.org/eclipsefdn/it/releng/gitlab-runner-service/gitlab-ci-templates/-/blob/main/pipeline.gitlab-ci.yml).
Including all features from: 
* Compliance
* Container management
* Auto Devops 

### Dockerhub publication

The Eclipse Foundation owns the Eclipse organization and a couple of other project-specific organizations at https://hub.docker.com. You can ask to get a repository created on one of these organizations. We will set permissions so that committers have write access to this repo (you will need to share your Docker Hub ID with us).

You can also ask us to create a project-specific organization. The organization name needs to follow the pattern `eclipse-<projectname>`.


### Nexus: repo.eclipse.org

The Eclipse Nexus instance is hosted at: `https://repo.eclipse.org/`

This repository allows Eclipse projects to publish their build artifacts into a centralized repository.

Notes:
* Snapshots older than `7 days` are automatically removed weekly, with a minimum of 1 snapshot being retained.
* All snapshots for a given GAV are automatically removed 14 days after release.
* All snapshots not being not requested in the last 360 days will be automatically removed.


#### Repository creation

File a ticket and specify what project you'd like a Nexus repo for.

3 repositories are typically created:
* `group`: `https://repo.eclipse.org/content/repositories/<projectname>`, which groups both releases and snapshots repositories.
* `releases`: `https://repo.eclipse.org/content/repositories/<projectname>-releases/`, for publishing releases. Re-deploy is disabled.
* `snapshots`: `https://repo.eclipse.org/content/repositories/<projectname>-snapshots/`, for publishing snapshots. Re-deploy is enabled.


#### Deploying with maven

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

### Signing tool

see: [CBI Signing tool](https://github.com/eclipse-cbi/cbi/wiki#signing-tool)

### Supply Chain Security Best Practices

The Eclipse Foundation has authored an Open Source Software Supply Chain Best Practices document. We highly recommend Eclipse OSS projects read, understand and adopt these best practices as part of their role in the Supply Chain.

https://github.com/eclipse-cbi/best-practices/blob/main/software-supply-chain/osssc-best-practices.md 


### Secret management

Permissions management in GitLab allows all project leads to add the credentials they need from the UI via `project->settings->CI/CD`, `Variables` entry.

In terms of best practices, it is recommended not to forget to mask declared variables.
(GitLab CI/CD Variables Masking Documentation)[https://docs.gitlab.com/ee/ci/variables/#mask-a-cicd-variable]

Regarding secrets managed by the Eclipse Foundation, GitLab CI relies on an internal vault. All new requests must go through a helpdesk ticket, where the paths for pipeline configuration will be specified.

```yaml
sonar:
  stage: quality
  secrets:
    SONATYPE_USERNAME:
      vault: modeling.tmf.xtext/oss.sonatype.org/username@cbi
    SONATYPE_PASSWORD:
      vault: modeling.tmf.xtext/oss.sonatype.org/password@cbi
  script:
    - export USERNAME=$(cat $SONATYPE_USERNAME)
    - export PASSWORD=$(cat $SONATYPE_PASSWORD)
```

or with property `file: false`, secret values are put directly in the variable.

```yaml
sonar:
  stage: quality
  secrets:
    SONATYPE_USERNAME:
      vault: modeling.tmf.xtext/oss.sonatype.org/username@cbi
      file: false
    SONATYPE_PASSWORD:
      vault: modeling.tmf.xtext/oss.sonatype.org/password@cbi
      file: false
  script:
    - ...
```

NOTE: Variables coming from secrets are automatically masked.

### Build container image (BuildKit)

The Eclipse Foundation hosts a buildkit infrastructure to build safely container images from GitLab CI.

You can use the buildkit job template from the [gitlab-ci-templates](https://gitlab.eclipse.org/eclipsefdn/it/releng/gitlab-runner-service/gitlab-ci-templates) project.

e.g: 
```yaml
include:
  - project: 'eclipsefdn/it/releng/gitlab-runner-service/gitlab-ci-templates'
    file: '/jobs/buildkit.gitlab-ci.yml'

variables:
  CI_REGISTRY_IMAGE: docker.io/eclipsecbi/grac

buildkit:
  secrets:
    CI_REGISTRY_USER:
      vault: technology.cbi/docker.com/username@cbi
      file: false
    CI_REGISTRY_PASSWORD:
      vault: technology.cbi/docker.com/api-token@cbi
      file: false
```

Or use your own implementation inspired by the template file [buildkit.gitlab-ci.yml](https://gitlab.eclipse.org/eclipsefdn/it/releng/gitlab-runner-service/gitlab-ci-templates/-/blob/main/jobs/buildkit.gitlab-ci.yml).


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
      vault: technology.cbi/projects-storage.eclipse.org/id_rsa@cbi
    SSH_PRIVATE_KEY_PASSPHRASE:
      vault: technology.cbi/projects-storage.eclipse.org/id_rsa.passphrase@cbi
    script:
    - echo "Copy your artifacts with ssh."
    - ssh "genie.$EF_SHORT_NAME@$SSH_HOSTNAME" ls -l "$DOWNLOADS_PATH"
```

## Request and Allocation Process for Runners (Resource pack)

### Allocating Resource Packs

Each Eclipse Project has access to one Resources Pack for building by default. 

For some projects, that may not be enough. Projects sponsored by Eclipse Membership (via Project Lead) have additional Packs, based on membership level. These Packs can be allocated to projects. 

* Some resources are only available to Enterprise and Strategic members.
* Enterprise and Strategic members can engage with the Foundation to acquire additional Packs.

### Resource pack configuration

Considering the microservice aspect in the execution of GitLab CI pipelines, where the aim is to have dedicated jobs for different kinds of tasks and thus to have a large number of jobs running in parallel to execute a pipeline.

As a consequence, three types of build containers are proposed with the following specifications: 

| |Small	|Medium	|Large|
|-|-------|-----------|------|
|cpu req|250m	|1000m	|2000m|
|cpu limit|500m	|2000m	|4000m|
|mem|1024Mi	|4096Mi	|8192Mi|

The distribution of concurrency is based on the resource pack specifications as follows:

|# Resource packs	|1	|2	|3	|4	|5	|10|
|-------------------|---|---|---|---|---|--|
|Concurrent Small 	|3	|5	|7	|9	|11	|21|
|Concurrent Medium	|1	|2	|3	|4	|5	|10|
|Concurrent Large	|0	|0	|1	|1	|2	|5 |
|max concurrency	|4	|7	|11	|14	|18	|36|

NOTE:
* 2 basics per resource pack starting from 3
* 1 advance per resource pack
* 1 expert every 2 resources pack

### Push the limits

The resource pack definition draws a global framework within which one or more project pipelines can run. In cases where a job requires more resources for a pipeline, projects are not limited to the `small`/`medium`/`large` runner templates but can benefit from additional resources within the boundaries of the resource pack.

Through the definition of jobs in GitLab Runner, projects have direct control over these customizations with the definition of variables such as `KUBERNETES_MEMORY_LIMIT_OVERWRITE_MAX_ALLOWED`, `KUBERNETES_MEMORY_REQUEST_OVERWRITE_MAX_ALLOWED`, ...

 For more information: [Overwrite container resources](https://docs.gitlab.com/runner/executors/kubernetes/#overwrite-container-resources)

|# Max Overwrite Allowed/Resource packs	|1	|2	|3	|
|-------------------|---|---|---|
| KUBERNETES_CPU_REQUEST_OVERWRITE_MAX_ALLOWED   | 1750m | 3250m | 6750m |
| KUBERNETES_CPU_LIMIT_OVERWRITE_MAX_ALLOWED     | 3500m | 6500m | 13500m |
| KUBERNETES_MEMORY_REQUEST_OVERWRITE_MAX_ALLOWED| 7168Mi | 13312Mi | 27648Mi |
| KUBERNETES_MEMORY_LIMIT_OVERWRITE_MAX_ALLOWED  | 7168Mi | 13312Mi | 27648Mi |

Calculation example: 
> Memory request calculation with one resource pack
> 3 small + 1 medium = 3 * 1024 + 1 * 4096 = 7168Mi   

NOTE: Resources are not only constrained by the resource pack definition but also by the resources available in the node cluster. If the definition is set too high, a job may struggle to find an available node for execution.

IMPORTANT: We encourage projects to take advantage of concurrent build jobs. Therefore, as a best practice, it's recommended to reduce code size by breaking it down into smaller modules and pieces, allowing for parallel execution rather than relying on a monolithic codebase.

### Dedicated Agent

| Agent type | Linux/Windows/macOS (VMs) |
|------------|---------------------------|
| vCPU 	| 4 |
| RAM 	| 8GiB |
| Disk 	| 100GB | 

### Resource Packs Included in Membership

|	| Associate / Contributing <br/> [€0, €15k] | Associate / Contributing <br/> [€15k, €20k] | Associate / Contributing <br/> [€25k, €50k] | Strategic <br/>	[€50k, €100k] |	Strategic <br/> [€100k, €500k] |
|-|-------------------------------------------|---------------------------------------------|---------------------------------------------|-------------------------------|--------------------------------|
| Resource packs | 1 | 2 | 3 | 5 | 10 |
| Dedicated Agents | 0 | 0 | 0 | 0 | 2 | 


### Assigning Resource Packs to a Project

Resource Packs are assigned by Member organizations of the Eclipse Foundation to Eclipse Projects they sponsor. Packs are assigned as a whole to a single project (i.e., can’t split Packs across multiple projects). A member can assign several packs to a single project.

Important: When asking for packs for your project, please ensure that project leads and your organization representatives are copied to the GitLab ticket. We require approval from project leads but assume immediate approval from organization representatives. We strongly advise you to seek authorization internally from your organization before opening such a request though. Should conflictual requests arise, the organization representatives will be asked to actively arbitrate.

To assign a pack to a project, please file a [ticket](https://gitlab.eclipse.org/eclipsefdn/helpdesk)

By default, resource packs are assigned build agents. In some cases, it may be required to scale up the Jenkins master. In such a case, we can allocate resource packs to the master instance.
Sponsored Projects

A public [API of sponsored projects](https://api.eclipse.org/cbi/sponsorships) is accessible. Organizations can check how many Resource Packs they have left for project sponsoring on the [membership portal](https://membership.eclipse.org/portal/login). 


### Understand the impact of Resource Pack on the EF infrastructure 

Pods and containers definition: 

```plantuml

@startuml kubernetes

footer Kubernetes Plant-UML
scale max 1024 width

skinparam nodesep 10
skinparam ranksep 10


' Kubernetes
!define KubernetesPuml https://raw.githubusercontent.com/dcasati/kubernetes-PlantUML/master/dist

!includeurl KubernetesPuml/kubernetes_Common.puml
!includeurl KubernetesPuml/kubernetes_Context.puml
!includeurl KubernetesPuml/kubernetes_Simplified.puml

!includeurl KubernetesPuml/OSS/KubernetesSvc.puml
!includeurl KubernetesPuml/OSS/KubernetesIng.puml
!includeurl KubernetesPuml/OSS/KubernetesPod.puml
!includeurl KubernetesPuml/OSS/KubernetesRs.puml
!includeurl KubernetesPuml/OSS/KubernetesDeploy.puml
!includeurl KubernetesPuml/OSS/KubernetesHpa.puml

!includeurl KubernetesPuml/OSS/KubernetesQuota.puml
!includeurl KubernetesPuml/OSS/KubernetesLimits.puml
!includeurl KubernetesPuml/OSS/KubernetesNode.puml

!includeurl KubernetesPuml/kubernetes_Container.puml

' Kubernetes Components

Namespace_Boundary(podns, "Pod/Container Definitions") {
    Container_Boundary(runnerContainerBoundaries, "Pod Runner") {
        Container(runnerContainer, "Runner Container", "", "cpu: 100/200,\n mem: 128/256mi")
    }

    Container_Boundary(smallContainerBoundaries, "Small Pod Runner") {
        Container(smallBuildContainer, "Build Container", "", "cpu: 250/500,\n mem: 1Gi")
        Container(smallHelperContainer, "Helper Container", "", "cpu: 100/150,\n mem: 1Gi")
        Container(smallInitContainer, "Init Container", "temporary", "cpu: 100/150,\n mem: 128mi")
    }

    Container_Boundary(mediumContainerBoundaries, "Medium Pod Runner") {
        Container(mediumBuildContainer, "Build Container", "", "cpu: 1000/2000,\n mem: 4Gi")
        Container(mediumHelperContainer, "Helper Container", "", "cpu: 100/150,\n mem: 1Gi")
        Container(mediumInitContainer, "Init Container", "temporary", "cpu: 100/150,\n mem: 128m")
    }

    Container_Boundary(largeContainerBoundaries, "Large Pod Runner") {
        Container(largeBuildContainer, "Build Container", "", "cpu: 2000/4000,\n mem: 8Gi")
        Container(largeHelperContainer, "Helper Container", "", "cpu: 100/150,\n mem: 1Gi")
        Container(largeInitContainer, "Init Container", "temporary", "cpu: 100/150,\n mem: 128mi")
    }

    Container_Boundary(serviceContainerBoundaries, "Service Pod Runner") {
        Container(serviceContainer, "Service Container", "", "cpu: 500/1000,\n mem: 1/2Gi")
    }
}


@enduml

```

A concrete example of competing project pipelines running in the EF infrastructure: 

```plantuml

@startuml kubernetes

footer Kubernetes Plant-UML
scale max 1024 width

skinparam nodesep 10
skinparam ranksep 10


' Kubernetes
!define KubernetesPuml https://raw.githubusercontent.com/dcasati/kubernetes-PlantUML/master/dist

!includeurl KubernetesPuml/kubernetes_Common.puml
!includeurl KubernetesPuml/kubernetes_Context.puml
!includeurl KubernetesPuml/kubernetes_Simplified.puml

!includeurl KubernetesPuml/OSS/KubernetesSvc.puml
!includeurl KubernetesPuml/OSS/KubernetesIng.puml
!includeurl KubernetesPuml/OSS/KubernetesPod.puml
!includeurl KubernetesPuml/OSS/KubernetesRs.puml
!includeurl KubernetesPuml/OSS/KubernetesDeploy.puml
!includeurl KubernetesPuml/OSS/KubernetesHpa.puml

!includeurl KubernetesPuml/OSS/KubernetesQuota.puml
!includeurl KubernetesPuml/OSS/KubernetesLimits.puml
!includeurl KubernetesPuml/OSS/KubernetesNode.puml

!includeurl KubernetesPuml/kubernetes_Container.puml

' Kubernetes Components
Cluster_Boundary(cluster, "Eclipse Foundation Kubernetes Cluster") {
    
    Namespace_Boundary(nodens, "Nodes infrastructure") {
        KubernetesNode(node1, "Node 1", "")
        KubernetesNode(node2, "Node 2", "")
        KubernetesNode(node3, "Node ...", "")
    }

    Namespace_Boundary(ns, "Project Runner Namespace") {
       
        Container_Boundary(RunnerBoundaries, "Runner context") {
            KubernetesPod(runner, "Gitlab Runner", "")

            Container_Boundary(concurrentBoundaries, "Concurrent Jobs") {
                KubernetesPod(JobMedium, "Job1 Medium Runner \nBuild:\n cpu: 1000/2000,\n mem: 4Gi" , "")
                KubernetesPod(JobSmall1, "Job2 Small Runner \nBuild:\n cpu: 250/500,\n mem: 1Gi", "")
                KubernetesPod(JobSmall2, "Job3 Small Runner \nBuild:\n cpu: 250/500,\n mem: 1Gi", "")
                KubernetesPod(JobSmall3, "Job4 Small Runner \nBuild:\n cpu: 250/500,\n mem: 1Gi", "")
            }
            KubernetesPod(JobMediumPodService1, "Job1 Service\n cpu: 500/1000,\n mem: 1Gi/2Gi", "")
        }
        KubernetesLimits(limit,"Resource Pack 1", " ")
        
        Container_Boundary(ResourceBoundaries, "Resource limits") {
            
            KubernetesQuota(quota,"Resource Quotas \ncpu:2750/5100, \nmem: 12032/12288, \npods: 8", " ")
        }
    }

    Namespace_Boundary(nsOther, "Other Project Runner Namespace") {

        Container_Boundary(RunnerBoundariesOther, "Runner context") {
            KubernetesPod(runnerOther, "Gitlab Runner", "")
            KubernetesPod(JobSmall1Other, "Job1 Small Runner \nBuild: cpu: 250/500,\n mem: 1Gi", "")
        }
        KubernetesLimits(limitOther,"Resource Pack...", " ")
        Container_Boundary(ResourceBoundariesOther, "Resource limits") {
            KubernetesQuota(quotaOther,"Resource Quotas...", " ")
        }
    }
}

Rel(runner, JobMedium, " ")
Rel(runner, JobSmall1, " ")
Rel(runner, JobSmall2, " ")
Rel(runner, JobSmall3, " ")

Rel_Left(JobMedium, JobMediumPodService1, " ")

Rel(JobMedium, node1, " ")
Rel(JobSmall1, node2, " ")
Rel(JobSmall2, node2, " ")
Rel(JobSmall3, node3, " ")

Rel(runnerOther, JobSmall1Other, " ")
Rel(JobSmall1Other, node1, " ")

Rel_Down(limit, ResourceBoundaries, "Define Namespace Quotas")
Rel_Right(limit, RunnerBoundaries, "Define Runner Quotas")

Rel_Down(limitOther, ResourceBoundariesOther, "Define Namespace Quotas")
Rel_Right(limitOther, RunnerBoundariesOther, "Define Runner Quotas")

@enduml

```

## Service Level Objectives (SLO)

Most CBI services are Tier 2 - Best Effort, which means they are expected to be available at all times, and rapid restoration can be expected in the event of an outage. Eclipse Strategic Members can contact the Webmaster in certain cases of off-hours support.

Please see [IT Service Level Objectives](https://gitlab.eclipse.org/eclipsefdn/helpdesk/-/wikis/IT-Service-Level-Objectives) for more information on the Eclipse Foundation IT Services SLO.

## Support

* [HelpDesk](https://gitlab.eclipse.org/eclipsefdn/helpdesk/-/issues/new)
* [IT chat service room: #eclipsefdn.it:matrix.eclipse.org](https://chat.eclipse.org/#/room/#eclipsefdn.it:matrix.eclipse.org)
* [GitLab CI templates](https://gitlab.eclipse.org/eclipsefdn/it/releng/gitlab-runner-service/gitlab-ci-templates)
* [Grac!](https://gitlab.eclipse.org/eclipsefdn/it/releng/gitlab-runner-service/gitlab-runner-as-code)

## FAQ

### Target a specific runner

Q: **How can I target a specific runner for my GitLab CI/CD job?**
A: To target a specific runner for your job, you can use runner tags. Runner tags are labels assigned to runners that help you select the right runner for specific jobs.
Each Eclipse foundation GitLab runner comes with a set of default labels. 
I.e: 
* `prefix:ef-grac` 
* `cluster:okd-c1` 
* `type:groups` 
* `instance:technologie.cbi.grac`
* `ctx:releng-group` 
* `executor:kubernetes` 
* `kubenamespace:ef-grac-technologie-cbi-grac`
* `concurrent:8` 
* `outputLimit:100000` 
* `image:ubuntu:20.04` 
* `cpuLimit:8000` 
* `cpuRequest:1000` 
* `memoryLimit:16384` 
* `memoryRequest:2048` 
* `serviceCpuLimit:8000` 
* `origin:eclipse`


Q: **How do I assign extra tags to runners?**

A: Tags can be assigned to runners during runner registration, e.g: my-tag, java, docker, etc., based on the capabilities or characteristics of the runner.
This can be requested at any time, at runner creation or later by simply filling out a request in the helpdesk support.

NOTE: by default, runners are set up to run untagged jobs.

Q: **How do I use runner tags in my CI/CD job configuration?**

A: In your `.gitlab-ci.yml` file, you can use the `tags` keyword at the top-level description for pipeline definition or in the job configuration to specify the runner tags that the pipeline or the job should target.

At pipeline level:

```yaml
default:
  tags:
    - origin:eclipse
```

At job level: 

```yaml
my_job:
  tags:
    - origin:eclipse
  script:
    - echo "Running on a Eclipse foundation runner"
```

Q: **What if no runner matches the specified tags?**

A: If no runner matches the specified tags, the job won't run. Make sure that your runner tags correspond to the capabilities of your runners and the requirements of your jobs.

Q: **Is there a default runner if no tags are specified?**

A: GitLab CI will automatically select a runner that doesn't have any tags assigned if you don't specify tags for a job. However, for more control and specificity, it's recommended to use runner tags, especially the `origin:eclipse` tag.

### CPU/RAM specific configuration

Q: **Is it possible to create a pod with more CPU/RAM allocation?**

A: Specific runners can be configured for projects with more CPU/RAM allocation. 
WARNING: It's important to keep in mind that this kind of runner will be executed in a context constrained by the resource pack allocated to the project. This means that if the CPU or the RAM used by all executors at the same time exceeds the limit set by resource quotas can cause a build failure.

see: [Overwrite container resources](https://docs.gitlab.com/runner/executors/kubernetes/#overwrite-container-resources)

e.g: 

```yaml
build:
  stage: build
  variables:
    KUBERNETES_CPU_REQUEST: "3"
    KUBERNETES_CPU_LIMIT: "5"
    KUBERNETES_MEMORY_REQUEST: "6Gi"
    KUBERNETES_MEMORY_LIMIT: "6Gi"
```

### Shared Runner

Q: **Can I use shared runners for my project?**

A: No, it is not possible to use shared runners in the Eclipse Foundation's infrastructure. This is because shared runners do not align with the resource pack per project approach and the sponsorship model that the Eclipse Foundation follows. Each project at the Eclipse Foundation has its resource pack and associated resources, making shared runners incompatible with this model. 

### Docker commands in your CI/CD jobs

Q: **Is the Docker's command enabled in the infrastructure?**

A: No, Docker's privilege mode is `not enabled` in the infrastructure, therefore, `docker` client can't be directly called in a build, even `docker compose`, ...

This decision aligns with the best practices recommended with our OKD infrastructure. The Eclipse Foundation's infrastructure prioritizes security and follows industry-standard guidelines to ensure a safe and controlled environment. 

### GitLab CI Services

Q: **Can I use GitLab CI services in my pipeline?**

A: GitLab CI services are not recommended for the moment. This is not factored into the resource pack calculation and their usage can potentially lead to build failure. 

## Known issues

### The secrets provider can not be found. Check your CI/CD variables and try again.

For a Gitlab runner to interact with the secret manager, several CI variables must be configured. By default, these variables are set at the GitLab group level during GitLab runner initialization with `Grac!`'s scripts: `VAULT_SERVER_URL`, `VAULT_AUTH_ROLE`, `VAULT_AUTH_PATH`.

If they are missing, please create an issue. [helpdesk](https://gitlab.eclipse.org/eclipsefdn/helpdesk/-/issues/new) 


### Error validating token: invalid issuer (iss) claim

```shell
ERROR: Job failed (system failure): resolving secrets: initializing Vault service: preparing authenticated client: authenticating Vault client: writing to Vault: api error: status code 400: error validating token: invalid issuer (iss) claim
```

This error message means that the secret audience is not configured. 

Two ways of fixing this. 

1. Import `secrets.gitlab-ci.yml`

```yaml
include:
  - project: "eclipsefdn/it/releng/gitlab-runner-service/gitlab-ci-templates"
    file: "jobs/secrets.gitlab-ci.yml"

build:
  stage: build
  extends: 
    - .secrets
```

2. Configure `id_tokens`: 
     
```yaml
build:
  stage: build
  id_tokens:
      VAULT_ID_TOKEN:
        aud: https://gitlab.eclipse.org
```

## Security consideration

### Mask CI password variables

To ensure the protection of sensitive data like credentials, it's imperative to never forget to mask passwords managed by the project itself. 

https://docs.gitlab.com/ee/ci/variables/#mask-a-cicd-variable

WARN: Common errors with mask password:

```
This value cannot be masked because it contains the following characters: &
```
