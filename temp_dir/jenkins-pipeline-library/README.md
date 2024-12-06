# Jenkins Pipeline Library

This repository is here to help understand and leverage the capabilities of the Jenkins Pipeline Library (`jenkins-pipeline-library`). 

This library is designed to streamline and standardize Jenkins pipeline configurations across projects according to Eclipse Foundation infrastructure specificities.

* `ContainerBuild`: Build docker images in eclipse foundation infrastructure (based on buildkit) and publish to any container registry such as docker.io, ...
* `Jamstack`: Build and publish Eclipse Foundation static website based on Hugo framework. 
* `Notification`: Send email notification

[[_TOC_]]

## Configuring Jenkins Shared Library

Jenkins Shared Libraries provide a way to centralize and reuse code across multiple pipelines. 

If you want to use this shared library named jenkins-pipeline-library follow these steps to configure it in Jenkins.

1. Jenkins Configuration:

* Log in to your Jenkins instance
* Navigate to "Manage Jenkins" > "Configure System" or to your multibranch pipeline project configuration

2. Configure Global Pipeline Libraries:

* "Pipeline Libraries" section.
* Click on "Add" to add a new library.

3. Library Configuration:

* Enter a name for the library:`releng-pipeline`
* Specify the default version (e.g., `main` or a specific `branch/tag`).
* Set the retrieval method: `Modern SCM for Git`
* Enter the library source: `https://gitlab.eclipse.org/eclipsefdn/it/releng/jenkins-pipeline-service/jenkins-pipeline-library``


Now, you can use the shared library in your Jenkinsfile by referencing functions or steps defined in jenkins-pipeline-library. For example:

```groovy
@Library('releng-pipeline') _

pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                relengPipeline.buildStep()
            }
        }
        
    }
}
```

By following these steps, you've configured and imported the `jenkins-pipeline-library` with the import name `releng-pipeline` into your Jenkins environment.

NOTE: shared library can also be configured at multibranch pipeline configuration level.

## ContainerBuild

Build docker images in eclipse foundation infrastructure (based on buildkit) and publish to any container registry such as docker.io, ...

### Using containerBuild in a stage

```groovy
@Library('releng-pipeline') _

pipeline {
    agent any
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
                        credentialsId: '<jenkins-credential-id>',
                        name: 'docker.io/<namespace-name>/<container-name>',
                        version: 'latest'
                    )
                }
            }
        }
    }
}
```

IMPORTANT: Don't forget to configure the `HOME` env!

### containerBuild as a Pipeline

Define a full pipeline to build and deploy an image to a registry from a project.

```groovy
@Library('releng-pipeline') _

containerBuildPipeline(
    credentialsId: '<jenkins-credential-id>',
    name: 'docker.io/<namespace-name>/<container-name>',
    version: 'latest'
)
```

NOTE: No need to define the agent here. Can be overridden with `kubeAgentYmlFile` param.

### Advanced Configuration

| Parameter        | Default Value | Description                                      | Required |
| ---------------- | ------------- | ------------------------------------------------ | -------- |
| credentialsId    | null          | Registry credentials                             | Yes      |
| registry         | docker.io     | Default Docker registry                          | No       |
| name             | null          | Image name (default docker.io)                   | Yes      |
| version          | latest        | Default image version                            | No       |
| extraVersions    | []            | Allows to tag image with different versions      | No       |
| aliases          | null          | Adding extra aliases to container image          | No       |
| dockerfile       | Dockerfile    | Path to the Dockerfile                           | No       |
| context          | .             | Build context                                    | No       |
| push             | true          | Enable push by default                           | No       |
| buildArg         | ''            | Additional build arguments                       | No       |
| annotation       | true          | Enable image annotations by default              | No       |
| latest           | false         | Tag container image with latest version          | No       |
| debug            | false         | Default debug mode                               | No       |
| kubeAgentYmlFile | null          | Kubernetes agent configuration YAML file (only available in containerBuildPipeline) | No       |

### More use case

More examples are available in the sample project: [jenkins-pipeline-library-sample](https://gitlab.eclipse.org/eclipsefdn/it/releng/jenkins-pipeline-service/jenkins-pipeline-library-sample/-/tree/main/src/containerBuild)

More use cases in the test suite: [jenkins-pipeline-library-sample test suite](https://gitlab.eclipse.org/eclipsefdn/it/releng/jenkins-pipeline-service/jenkins-pipeline-library-sample/-/blob/main/test/containerBuild/Jenkinsfile.containerBuildStageTestSuite)

### Common errors

1. Error: `mkdir /.docker: permission denied`

Define HOME env var

```groovy
environment {
    HOME = "${env.WORKSPACE}"
}
```

2. WorkflowScript: 25: Expected a step @ line xx, column xx.

Adding script tag around your specific code

```groovy
steps {
    String name = env.REPO_NAME + '/alpine'
    String versions = ['edge', '3.16', '3.17', '3.18']
    versions.each { version ->
    container('containertools') {
        containerBuild(
        ...
        )
    }
  }
}
```

to 

```groovy
steps {
    script {
        String name = env.REPO_NAME + '/alpine'
        String versions = ['edge', '3.16', '3.17', '3.18']
        versions.each { version ->
        container('containertools') {
            ...
            )
        }
        }
    }
}
```

## Jamstack: Hugo website

Build and publish a static website based on Hugo framework. 

### Configuration

```groovy
@Library('releng-pipeline') _

hugo (
  appName: 'site-name.org',
  productionDomain: 'site-name.org'
)
```

* The Hugo pipeline has several [options](https://gitlab.eclipse.org/eclipsefdn/it/releng/jenkins-pipeline-library/-/blob/main/src/org/eclipsefdn/jenkins/preview/Preview.groovy) that you can customize.
* Remove unnecessary `Dockerfile`, `docker-compose.yml`, Kubernetes resource files (e.g. the folder `k8s/` or `src/main/k8s`)


### Jenkins job changes

* If the website is on GitLab, ensure that the job configuration uses `GitLab username/token` as **Checkout Credentials** rather than `GitLab username/password` in the **Branch Sources** section of the job configuration.
  * Until done, you may experience build failures with `curl: (22) The requested URL returned error: 401` in the build logs.

### Nginx front LB changes

* Once the change above led to a proper preview being deployed, it's time to deploy to production.
  * Merge the change
  * Change the front load balancer configuration, e.g. change `proxy_pass http://www-http/;` to `proxy_pass https://okd-ingress-tls$request_uri;` if the previous site was deployed on `www-http` VMs.
  * If the site was already served from the cluster, you will need to do 2 things, and it will create a short downtime (otherwise, you're done)
    * Remove all Kubernetes resources associated with the current production and staging app/site (ask `releng/infra team` to do so)
    * Restart a build for the production branch of the site.

### How to deploy a jamstack pipeline in a new namespace?

* Create a new namespace in the target cluster [webmaster]
  `oc create ns ${NAMESPACE}`

* Create the `ServiceAccount` with permissions by using the project [jamstack-sa](https://gitlab.eclipse.org/eclipsefdn/it/releng/jenkins-pipeline-service/jamstack-sa).

### How to activate authBasic

```groovy
hugo(
  appName: ...,
  ...
  deployment: [
    domain: ...,
    authBasic: true
  ]
)
```

Create and set up the secret in Kubernetes: 

```shell
sudo apt-get install apache2-utils
sudo htpasswd  -bc /tmp/.htpasswd my_user my_passwd
oc create secret generic <appName>-authbasic-secret --from-file=htpasswd=/tmp/.htpasswd -n ${NAMESPACE}
```

### Manage Dockerhub private registry

Create a secret based on the project bot and in the project Kubernetes namespace. 

```shell
oc create secret docker-registry --namespace ${NAMESPACE} dockerconfigjson-jamstack \
    --docker-server=docker.io \
    --docker-username=<bot_name> \
    --docker-password=<bot_token> \
    --docker-email=<bot_name>@eclipse.org \ 
```    

Link the secret to the default service account.

```shell 
oc secrets link --namespace ${NAMESPACE} default dockerconfigjson-jamstack --for=pull
```

### How to develop this preview library

This library depends on the kube-deploy Jsonnet library hosted at https://gitlab.eclipse.org/eclipsefdn/it/releng/kube-deploy. Dependencies are managed by https://github.com/jsonnet-bundler/jsonnet-bundler. If you need to use a newer version of kube-deploy, you will have to update the `jsonnetfile.json` file, e.g. `resources/org/eclipsefdn/jamstack/deployment/jsonnetfile.json`. During pipeline execution, only `jb install` is called, not `jb update`

## Send notification

Allows to send email notifications on build status.

```groovy
 post {
    always {
      sendNotifications currentBuild
    }
  }
```

## How to develop 

The version used by default in the pipeline should be fixed at a given version (preferably via a tag) in the Jenkins configuration. You can test changes in the library by specifying a specific version when loading the library in the Jenkinsfile, e.g. `library "shared-library@main"`. See https://www.jenkins.io/doc/book/pipeline/shared-libraries/#library-versions for details.
