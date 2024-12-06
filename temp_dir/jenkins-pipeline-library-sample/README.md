# Jenkins Pipeline Library Sample

This repository is here to help for understanding and leveraging the capabilities of the Jenkins Pipeline Library (`jenkins-pipeline-library`). Its primary purpose is to provide examples of Jenkinsfiles that demonstrate the usage of the shared library but also to continuously test pipelines. 

This library is designed to streamline and standardize Jenkins pipeline configurations across projects according to eclipse foundation infrastructure specificities.

## Container Build / Declarative pipeline

### Define the Agent

```groovy
agent {
    kubernetes {
        yaml loadOverridableResource(
            libraryResource: 'org/eclipsefdn/container/agent.yml'
        )
    }
}
```

Load this specific agent kubernetes definition: https://gitlab.eclipse.org/eclipsefdn/it/releng/jenkins-pipeline-service/jenkins-pipeline-library/-/blob/main/resources/org/eclipsefdn/container/agent.yml[agent.yml]

Can be defined at pipeline or stage level. 


### Container Build Stage

Define a specific stage for building/publishing container to a registry.

```groovy
@Library('releng-pipeline') _

pipeline {
    agent any
    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
        disableConcurrentBuilds()
        timeout(time: 90, unit: 'MINUTES')
    }
    triggers {
        cron('H H * * H')
    }
    environment {
        HOME = "${env.WORKSPACE}"
    }
    stages {
        stage('build') {
            agent {
                kubernetes {
                    yaml loadOverridableResource(
                        libraryResource: 'org/eclipsefdn/container/agent.yml'
                    )
                }
            }
            steps {
                container('containertools') {
                    containerBuild(
                        credentialsId: 'e93ba8f9-59fc-4fe4-a9a7-9a8bd60c17d9',
                        name: 'docker.io/eclipsecbi/jenkins-pipeline-library-sample',
                        version: 'latest'
                    )
                }
            }
        }
    }
}
```

### Container Build with groovy code

Using directly groovy class from the library to connect to the registry and build/publish to that registry.

```groovy
@Library('releng-pipeline')

import org.eclipsefdn.jenkins.container.ContainerBuild

ContainerBuild containerBuildInstance = new ContainerBuild(this)

pipeline {
    agent any
    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
        disableConcurrentBuilds()
        timeout(time: 90, unit: 'MINUTES')
    }
    triggers {
        cron('H H * * H')
    }
    environment {
        HOME = "${env.WORKSPACE}"
    }    
    stages {
        stage('build') {
            agent {
                kubernetes {
                    yaml loadOverridableResource(
                        libraryResource: 'org/eclipsefdn/container/agent.yml'
                    )
                }
            }
            steps {
                container('containertools') {
                    script {
                        containerBuildInstance.login('e93ba8f9-59fc-4fe4-a9a7-9a8bd60c17d9')
                        containerBuildInstance.build('docker.io/eclipsecbi/jenkins-pipeline-library-sample', 'latest')
                    }
                }
            }
        }
    }
    
}
```

### Use Container Build Pipeline

Define a full pipeline to build and deploy container image to a registry from a project.

NOTE: No need to define the agent here. Can be overrided with `kubeAgentYmlFile` param.

```groovy
@Library('releng-pipeline') _

containerBuildPipeline(
    credentialsId: 'e93ba8f9-59fc-4fe4-a9a7-9a8bd60c17d9',
    name: 'docker.io/eclipsecbi/jenkins-pipeline-library-sample',
    version: 'latest'
)
```

### Advanced Configuration


| Parameter         | Default Value | Description                                   | Required  |
| -------------     | --------------| ----------------------------------------------| --------- |
| credentialsId     | null          | Registry credentials                          | Yes       |
| registry          | docker.io     | Default Docker registry                       | No        |
| name              | null          | Image name (default docker.io)                | Yes       |
| version           | latest        | Default image version                         | No        |
| extraVersions     | []            | Allows to tag image with different versions   | No        |
| aliases           | null          | Adding extra aliases to container image       | No        |
| dockerfile        | Dockerfile    | Path to the Dockerfile                        | No        |
| context           | .             | Build context                                 | No        |
| push              | true          | Enable push by default                        | No        |
| buildArg          | ''            | Additional build arguments                    | No        |
| annotation        | true          | Enable image annotations by default           | No        |
| latest            | false         | Tag container image with latest version       | No        |
| debug             | false         | Default debug mode                            | No        |
| kubeAgentYmlFile  | null          | Kubernetes agent configuration YAML file (only available in containerBuildPipeline) | No  |


## Container Build / Scripted pipeline


```groovy
@Library('releng-pipeline') _

timeout(time:90, unit:'MINUTES') {
    podTemplate(yaml: loadOverridableResource(libraryResource: 'org/eclipsefdn/container/agent.yml')) {
        node(POD_LABEL) {
            properties([
                buildDiscarder(logRotator(numToKeepStr: '5')),
                disableConcurrentBuilds(),
                pipelineTriggers([
                    cron('H H * * H')
                ])
            ])
            
            checkout scm

            withEnv(["HOME=${env.WORKSPACE}"]){
                stage('build') {
                    container('containertools') {
                        containerBuild(
                            credentialsId: 'e93ba8f9-59fc-4fe4-a9a7-9a8bd60c17d9',
                            name: 'docker.io/eclipsecbi/jenkins-pipeline-library-sample',
                            version: 'latest'
                        )
                    }
                }
            }
        }
    }
}

```
