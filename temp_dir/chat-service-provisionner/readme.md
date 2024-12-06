<!--
SPDX-FileCopyrightText: 2023 eclipse foundation
SPDX-License-Identifier: EPL-2.0
-->

# Chat Service Provisioner

Chat Service Provisioner is a tool tailored to simplify the process of creating rooms and spaces within Chat Service Matrix Synapse instance.
Using of Infrastructure as Code (IaC) concept, this project gives the ability to define spaces and rooms programmatically.

[[_TOC_]]

# How It Works?

**Define Configuration**: Use a yaml syntax to define room or space configuration in code.

**Run Provisioner**: Execute the Synapse Space Provisioner as a kubernetes cronjob and providing the configuration file as input in a kubernetes config file.

**Automated Creation**: The provisioner interacts with Chat Service Matrix Synapse instance's API to create rooms and spaces based on the defined configuration.

# Getting started!

## Project file definition

All room and space definitions are stored in the `project.yaml` file.

For documentation reference, check this [readme.md](https://gitlab.eclipse.org/eclipsefdn/it/releng/chat-service/chat-service-sync/-/blob/main/readme.md)
For project room definition, see this section: [project room space definition](https://gitlab.eclipse.org/eclipsefdn/it/releng/chat-service/chat-service-sync/-/blob/main/readme.md#project-roomspace-definition)


Example of adding a new room:

```yaml
  - tools.mylyn:
      rooms:
      - alias: '#tools.mylyn'
        name: 'Eclipse Mylyn'
        parent: *defaultProjectSpace
        topic: |
          Eclipse Mylyn is a Task-Focused Interface for Eclipse that reduces information overload and makes multi-tasking easy. The mission of the Mylyn project is to provide: 1. Frameworks and APIs for Eclipse-based task and Application Lifecycle Management (ALM) 2. Exemplary tools for task-focused programming within the Eclipse IDE. 3. Reference implementations for open source ALM tools used by the Eclipse community and for open ALM standards such as OSLC The project is structured into sub-projects, each representing an ALM category and providing common APIs for specific ALM tools. The primary consumers of this project are ALM ISVs and other adopters of Eclipse ALM frameworks.  Please see the project charter for more details. Mylyn makes tasks a first class part of Eclipse, and integrates rich and offline editing for repositories such as Bugzilla, Trac, and JIRA. Once your tasks are integrated, Mylyn monitors your work activity to identify information relevant to the task-at-hand, and uses this task context to focus the Eclipse UI on the interesting information, hide the uninteresting, and automatically find what's related. This puts the information you need to get work done at your fingertips and improves productivity by reducing searching, scrolling, and navigation. By making task context explicit Mylyn also facilitates multitasking, planning, reusing past efforts, and sharing expertise.
```

Example of adding a space:

```yaml
  - oniro:
      rooms:
      - alias: '#oniro'
        type: space
        name: 'Oniro'
        topic: |
          The mission of the Eclipse Oniro is the design, development, production and maintenance of an open source software platform, having an operating system, an ADK/SDK, standard APIs and basic applications, like UI, as core elements, targeting different industries thanks to a next-generation multi-kernel architecture, that simplifies the existing landscape of complex systems, and its deployment across a wide range of devices.
```

## Generate secrets

Execute:  `secrets/gen-secrets.sh {env}` (env = dev/prod/staging)

It will store secrets under: `/environments/chat-matrix/{env}/.secrets`

## Install jsonnet dependencies

Requires `jsonnet-bundler` to be installed: https://github.com/jsonnet-bundler/jsonnet-bundler

```bash
jb install
```

## Deploy with apply script

```bash
./apply.sh dev
```

## Deploy manually

### tanka

see doc installation tanka: `https://tanka.dev/install`

```bash
tk show "environments/chat-matrix/dev"
tk apply "environments/chat-matrix/dev"
```

If you want to check the Kubernetes file before applying, try exporting with this command:

```bash
tk show --dangerous-allow-redirect "environments/chat-matrix/dev" > ./k8s/chat-matrix-dev.yaml
```

### Cronjob

```bash
JOB_NAME="${USERNAME}-manual-run-001"
NAMESPACE="chat-matrix-prod"
kubectl delete job ${JOB_NAME} -n ${NAMESPACE}
kubectl create job -n ${NAMESPACE} --from=cronjob/chatservice-sync ${JOB_NAME}
```

Accept all room invitations and replay the job.
This will allow the script to add permissions for users. 

