<!--
SPDX-FileCopyrightText: 2024 eclipse foundation
SPDX-License-Identifier: EPL-2.0
-->

# GitLab Runner As Code - GRAC!

`GRAC!` is an infrastructure as code for GitLab runner in Kubernetes infrastructure dedicated to projects hosted by the Eclipse Foundation at [gitlab.eclipse.org](https://gitlab.eclipse.org).

[TOC]

## What is GRAC?

The goal of `GRAC!` is to make the administration of hundreds of GitLab runner instances on a Kubernetes-based infrastructure bearable. It uses automation, templates and a configuration-as-code approach. `GRAC!` consist of a set of custom shell scripts and a [jsonnet](https://jsonnet.org) generation. It relies also on the `Docker CLI`, `OpenShift CLI`.

## Why GRAC?

With the implementation of Jenkins instance as code at Eclipse Foundation under the name of [JIRO](https://github.com/eclipse-cbi/jiro), and over +250 instances in production, Gitlab Continuous Integration has been requested by projects to be supported. 
So as a natural extension, `GRAC!` is Born, under the Woods: same approach and technologies.

`GRAC!` allows a lower administration overhead for recurring tasks like setting up a new GitLab runner for projects/groups, configuring, allowing resources, handling specific requests, etc.

## Before starting

### Instance notion

Each group or project in GitLab is linked to an instance reference. At the foundation, it refers to project_id. 
But this can be customized very easily depending on the organization you want to set up.
 
Group: https://gitlab.eclipse.org/eclipsefdn/it/releng
* Instance: `technology.cbi`

Configuration is generated in the directory: `./instances/technology.cbi`

### Kubernetes Context

All commands in GRAC depend on kube `current-context`.

Before launching a command, it is recommended to verify the current target: `kubectl config current-context` or `kubectx`

All generation files will be attached to this context

## CBI Configuration 

Create file `~/.cbi/config`

```json
{
  "kubeconfig": {
    "path": "~/.kube/config",
  },
  "gitlab.com-token": "XXXXXXXXXXXXXX",
  "gitlab.eclipse.org-token": "XXXXXXXXXXXXXX",
}
```

`kubeconfig`: allow to configure the path to the Kubernetes configuration file. 
Default: `~/.kube/config`

`<gitlab_address>-token`: Personal Acces Token from GitLab. Need to be created from the profile UI in GitLab. e.g: [PAT](https://gitlab.eclipse.org/-/profile/personal_access_tokens).

## Kube configuration

```yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ...
    server: https://api.xxxx.org
  name: <cluster-ctx>
contexts:
- context:
    cluster: <cluster-ctx>
    namespace: grac-...
    user: sebastien.heurtematte@eclipse-foundation.org/xxxx
  name: <cluster-ctx>
current-context: <cluster-ctx>
kind: Config
preferences: {}
users:
- name: sebastien.heurtematte@eclipse-foundation.org/xxxxx
  user:
    token: sha256~XXXXXXX
```

## Build locally docker image

```shell
docker build . --tag eclipsecbi/grac 
docker pull eclipsecbi/grac 
```

## Execute command

```shell
./grac.sh deploy technology.cbi
```

or directly with the Docker CLI:

```shell
docker run \
    -v "${PWD}":/app \
    -v ~/.cbi/config:/home/grac/.cbi/config \
    -v ~/.kube/config:/home/grac/.kube/config \
    -v /etc/timezone:/etc/timezone:ro \
    -v /etc/localtime:/etc/localtime:ro \
    --env GITLAB_URL=https://gitlab.com
    --env PERSONAL_ACCESS_TOKEN=XXXXXXXXXXX
    --env KUBECONFIG=/home/grac/.kube/config \
    --network host \
    eclipsecbi/grac make deploy instance=technology.cbi
```

IMPORTANT: All command executed depends on Kubernetes context. 

Find the current context: `kubectl config current-context` or `kubectx`

## Tasks

| Task           | Description                                                                                                            | 
|----------------|------------------------------------------------------------------------------------------------------------------------|
| `create`       | Create directory for the project/group under ./instance with by default `config.jsonnet` and `grac.jsonnet` configure  |
| `config`       | Generation of all jsonnet file under `./instance/project_name/env_name/target`                                         |
| `k8s`          | Generation of configmap which is based on templating processor, `genconfig` is also execute with this task             |
| `registration` | Gitlab Runner registration and store token kubernetes secrets              |
| `deploy`       | Deploy all configuration to kubernetes cluster and restart deployment after a reconfiguration                          |
| `restart`      | Restart all deployment from kubernetes cluster                                                                         |
| `delete-k8s`   | Delete all kubernetes cluster configuration files                                                                      |
| `delete-runner`| Delete all runner from gitlab                                                                                          |
| `delete`       | Delete all runner and k8s configuration file                                                                           |
| `init`         | Generate an instance and deploy                                                                                        |
| `replay`       | Delete, regenerate an instance and redeploy                                                                            |
| `reload`       | Regenerate an instance and redeploy                                                                                    |
| `clean`        | Delete target directory generate by `k8s` or `genconfig` tasks                                                         |
| `resume`       | Print runner infos from all deployment                                                                                 |

![Grac Command Graphs](./makefile.png)

*Made with: `makefile2dot | dot -Tpng > makefile.png`*

## Tasks `*-all`

All tasks defined have an equivalent with `-all` suffix. 
Ex: `create-all`, `deploy-all`, `k8s-all`, ... 

They apply to all instances of the directory `./instances`. 
And depends on the Kubernetes context. 

## Create a new instance

```shell
./grac.sh create oniro.oniro-core
```

NOTE: `oniro.oniro-core` must match an existing namespace in GitLab like `https://gitlab.org/oniro/oniro-core`

Custom creation when an instance name is not the same as the GitLab project namespace.

```shell
./grac.sh create foundation-internal.infra -a eclipsefdn/...
```

Change project definition if necessary:

```shell
./instances/oniro.oniro-core/<cluster-ctx>/grac.jsonnet
```

And generate k8s files and deploy to the cluster

```shell
./grac.sh init oniro.oniro-core
```

## Add clean-up pod with ttl  

Kubernetes configuration file `pod-cleanup-example.yml` allows defining policy around GitLab runner pod especially if they stay stuck for any reason.
It's based on this project [gitlab-runner-pod-cleanup](https://gitlab.com/gitlab-org/ci-cd/gitlab-runner-pod-cleanup). 

Annotation should be added to the pod: 

grac configuration `podAnnotations` to add: 
```json
  kubernetes+:{
    podAnnotations+:{
      'pod-cleanup.gitlab.com/ttl':'6h',
    },
  },
```

### use a namespace RegEx

A RegEx can be defined to apply the policy on a specific namespace:

ex:

```yaml
  - name: POD_CLEANUP_KUBERNETES_NAMESPACES
    value: grac* 
```

grac configuration `prefix` to add: 

```json
  project+: {
    prefix: 'grac',
```


