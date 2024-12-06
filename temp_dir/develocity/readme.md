# Develocity Service

The Develocity Service at the Eclipse Foundation aims to help Eclipse projects in enabling [Develocity](https://gradle.com/develocity) by providing a seamless integration to CI pipeline, as well as local builds (opt-in). 

IMPORTANT: The Eclipse Develocity instance is currently in an experimental phase (staging). During this period, we will integrate the platform with projects interested in participating. Following this integration phase, we will assess the value of Develocity for the community based on the feedback from these pilot projects, its impact on the foundation's infrastructure, and the effort required to maintain it in operational condition.  

At the end of this period, and if the feedback is positive, the platform will move into a production phase. Data from the staging platform will not be migrated.

NOTE: This experimentation is currently focused primarily on Gradle/Maven projects. However, if a project wants to experiment with other tools, we strongly encourage it. Doing so will provide even more feedback on the overall scope of the product, and thus strengthen the conclusions of this experiment.

[TOC]

## What is Develocity?

[Develocity](https://gradle.com/develocity/) is a product developed by [Gradle](https://gradle.com/) as a build data platform and performance management tool aiming to monitor, debug, optimize and accelerate the build and delivery process.

It provides insights into build times, tests, requests, caches, ... Helping identify inefficiencies/bottlenecks and offers recommendations to improve build speed and reliability. 

Develocity integrates seamlessly with many CI: Jenkins, GitLab CI, Github Acions, ...
It supports as well many build tools: Gradle, Maven, sbt, bazel

The Eclipse Foundation Develocity instance (available at [https://develocity-staging.eclipse.org/](https://develocity-staging.eclipse.org/)) is fully featured and freely available for use by all Eclipse Foundation projects. When a project onboards its product to Develocity, every CI build and every local build from an authenticated Eclipse committer uploads a Build Scan®. A Build Scan® contains deep build insights that can help troubleshoot build failures and performance issues. By aggregating these Build Scans®, Develocity also provides:

- Dashboards to view all historical Build Scans® and performance trends over time
- Build failure analytics for enhanced investigation and diagnosis of build failures
- Test failure analytics to better understand trends and causes around slow, failing, and flaky tests


## Quick start!

The Develocity platform can be accessed at [https://develocity-staging.eclipse.org/](https://develocity-staging.eclipse.org/) by using your Eclipse account: email / password.

Generically, onboarding a project to Develocity consists of:
- Applying Develocity to the build 
- Configuring Develocity to:
  - Send Build Scans® to https://develocity-staging.eclipse.org
  - Always publish Build Scans® if authenticated
  - Upload Build Scans® in the background for local builds and in the foreground for CI builds
  - Apply Common Custom User Data to the build
- Configuring build caching:
  - Enable local caching for local builds only (unless CI builds are already using local cache)
  - Disable remote caching (unless builds are already using a remote cache, or you want to use / experiment with it)

### Gradle

The following sample shows a minimal Develocity configuration for a project building with Gradle 6 or above, using Groovy build scripts. A kotlin script sample (`setting.gradle.kts`) is available [here](https://github.com/gradle/develocity-build-config-samples/blob/main/common-develocity-gradle-configuration-kotlin/settings.gradle.kts).

#### settings.gradle

```groovy
plugins {
    id 'com.gradle.develocity' version '3.18.1'
    id 'com.gradle.common-custom-user-data-gradle-plugin' version '2.0.2'
}

def isCI = System.getenv('CI') != null // adjust to your CI provider

develocity {
    server = "https://develocity-staging.eclipse.org"
    projectId = "project-identifier" // adjust to your project identifier / descriptor
    buildScan {
        uploadInBackground = !isCI
        publishing.onlyIf { it.isAuthenticated() }
        obfuscation {
            username { _ -> "eclipse-" + System.getenv("EF_SHORT_NAME") + "-bot" }
            ipAddresses { addresses -> addresses.collect { address -> "0.0.0.0" } }
        }
    }
}

buildCache {
    // disable local caching in CI, unless already used by the build
    local {
        enabled = !isCI
    }
    // disable remote caching, unless already used by the build or you want to use / experiment with it
    remote(develocity.buildCache) {
        enabled = false
        push = isCI
    }
}

rootProject.name = 'project-name' // adjust to your project name
```
See the [Develocity compatibility chart](https://docs.gradle.com/enterprise/compatibility/#develocity_compatibility) for the most recent version of the Develocity Gradle Plugin compatible with the currently installed version of Develocity at [https://develocity-staging.eclipse.org/](https://develocity-staging.eclipse.org/).

See the [Common Custom User Data Gradle Plugin releases page](https://github.com/gradle/common-custom-user-data-gradle-plugin/releases) for the most recent version of the Common Custom User Data Gradle Plugin.

For information about configuring Develocity for Gradle versions before 6, see the [Develocity Gradle Plugin User Manual](https://docs.gradle.com/enterprise/gradle-plugin/).

### Maven

The following sample shows a Develocity configuration for a Maven project:

#### .mvn/extensions.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<extensions>
    <extension>
        <groupId>com.gradle</groupId>
        <artifactId>develocity-maven-extension</artifactId>
        <version>1.22.2</version>
    </extension>
    <extension>
        <groupId>com.gradle</groupId>
        <artifactId>common-custom-user-data-maven-extension</artifactId>
        <version>2.0.1</version>
    </extension>
</extensions>
```

#### .mvn/develocity.xml

```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<develocity
    xmlns="https://www.gradle.com/develocity-maven" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="https://www.gradle.com/develocity-maven https://www.gradle.com/schema/develocity-maven.xsd">
  <server>
    <url>https://develocity-staging.eclipse.org</url>
  </server>
  <projectId>project-identifier</projectId> <!-- adjust to your project identifier / descriptor -->
  <buildScan>
    <obfuscation>
      <username>#{'eclipse-' + env['EF_SHORT_NAME'] + '-bot'}</username>
      <ipAddresses>0.0.0.0</ipAddresses>
    </obfuscation>
    <publishing>
      <onlyIf>
        <![CDATA[authenticated]]>
      </onlyIf>
    </publishing>
    <backgroundBuildScanUpload>#{isFalse(env['CI'])}</backgroundBuildScanUpload> <!-- adjust to your CI provider -->
  </buildScan>
  <buildCache>
    <local>
      <enabled>#{isFalse(env['CI'])}</enabled>
    </local>
    <remote>
      <enabled>false</enabled>
      <storeEnabled>#{isTrue(env['CI'])}</storeEnabled> <!-- adjust to your CI provider -->
    </remote>
  </buildCache>
</develocity>
```

See the [Develocity compatibility chart](https://docs.gradle.com/enterprise/compatibility/#develocity_compatibility_2) for the most recent version of the Develocity Maven Extension compatible with the currently installed version of Develocity at [https://develocity-staging.eclipse.org/](https://develocity-staging.eclipse.org/).

See the [Common Custom User Data Maven Extension releases page](https://github.com/gradle/common-custom-user-data-maven-extension/releases) for the most recent version of the Common Custom User Data Gradle Plugin.

## CI integration

### Request a CI integration

A Develocity integration within CI can be requested by filling a ticket on the [helpdesk](https://gitlab.eclipse.org/eclipsefdn/helpdesk/-/issues/new). 
Please ensure your project lead has approved with a +1 the request. 

This integration will provide: 
* A Develocity CI Bot with CI permission on the platform
* Secrets integration with the Secrets Manager
* Accessing secrets from any CI
* Accessing Develocity platform from any CI

### CI tools integration

https://docs.gradle.com/develocity/get-started/#integrating_your_ci_tool

#### Jenkins

```groovy
def secrets = [
  [path: 'cbi/<project_id>/develocity.eclipse.org', secretValues: [
    [envVar: 'DEVELOCITY_ACCESS_KEY', vaultKey: 'api-token']
    ]
  ]
]

pipeline {
    agent any
    tools {
        maven 'apache-maven-3.9.6'
        jdk 'openjdk-jdk17-latest'
    }
    stages {
        stage('Build') {
            steps {
                withVault([vaultSecrets: secrets]) {
                    sh 'mvn clean verify -Prelease -B'
                }
            }
        }
    }
}

```

#### GitLab CI

see: [GitLab CI templates](https://gitlab.eclipse.org/eclipsefdn/it/releng/gitlab-runner-service/gitlab-ci-templates)

1. Gradle

```yaml
include:
  - local: /jobs/develocity.eclipse.org.gitlab-ci.yml

develocity.eclipse.org-gradle-test:
  extends: 
    - .ef-build-develocity-gradle
```

2. Maven

```yaml
include:
  - local: /jobs/develocity.eclipse.org.gitlab-ci.yml

develocity.eclipse.org-mvn-test:
  extends: 
    - .ef-build-develocity-maven
```

This can be easily overwritten by extending `.ef-build-develocity`:

```yaml
develocity.eclipse.org-mvn-test:
  extends: .ef-build-develocity
  variables:
    MAVEN_OPTS: "-Dhttps.protocols=TLSv1.2 -Dmaven.repo.local=$CI_PROJECT_DIR/.m2/repository -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=WARN -Dorg.slf4j.simpleLogger.showDateTime=true -Djava.awt.headless=true"
    MAVEN_CLI_OPTS: "--batch-mode --errors --fail-at-end --show-version -DinstallAtEnd=true -DdeployAtEnd=true"
  script:
    - !reference [.injectDevelocityForMaven]
    - ./mvnw clean deploy -s settings.xml
```

#### GitHub Action

Prerequisite: Ask for a token: `DEVELOCITY_ACCESS_KEY` in your GitHub Organization.

1. Gradle: 
* https://docs.gradle.com/develocity/get-started/#github_actions
* https://github.com/gradle/gradle-build-action
  
```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout sources
      uses: actions/checkout@v4
    - name: Setup Gradle
      uses: gradle/actions/setup-gradle@v3
    - name: Build with Gradle
      run: ./gradlew build
      env:
          DEVELOCITY_ACCESS_KEY: ${{ secrets.DEVELOCITY_ACCESS_KEY }}
```

2. Maven: 
* https://docs.gradle.com/develocity/get-started/#github_actions
* https://github.com/gradle/develocity-actions


```yaml
jobs:
  build:  
    runs-on: ubuntu-latest
    steps:
      - name: Checkout sources
        uses: actions/checkout@v4
      - name: Setup Maven
        uses: gradle/develocity-actions/maven-setup@v1
      - name: Build with Maven
        run: ./mvnw clean package
        env:
            DEVELOCITY_ACCESS_KEY: ${{ secrets.DEVELOCITY_ACCESS_KEY }}
```

### Authenticating to [develocity-staging.eclipse.org](https://develocity-staging.eclipse.org/)

#### CI Builds
CI environments are most commonly configured to read access keys from an environment variable, stored as a secret. Onboarded Gradle and Maven CI builds will look for the environment variable `DEVELOCITY_ACCESS_KEY` and use its value to authenticate to [develocity-staging.eclipse.org](https://develocity-staging.eclipse.org/).

#### Local Builds

In order to authenticate a local development machine, Develocity offers automated access key provisioning:

- [Automated access key provisioning for Gradle builds](https://docs.gradle.com/develocity/gradle-plugin/current/#automated_access_key_provisioning) 
- [Automated access key provisioning for Maven builds](https://docs.gradle.com/develocity/maven-extension/current/#automated_access_key_provisioning)

When executed, the automated provisioning launches a web browser to [develocity-staging.eclipse.org](https://develocity-staging.eclipse.org/) and asks you to sign in. All Eclipse Foundation committers can log in using their Eclipse account: email / password.

#### Unauthenticated Builds

Builds that are not authenticated to Develocity will simply not publish a Build Scan®. A lack of authentication will not cause the build to fail and will not be shown to the user. This includes builds by unauthenticated Eclipse committers, unauthenticated CI systems, or community contributors.


### Best practices

#### Obfuscation

1. Gradle: `build.gradle.kts`

doc: https://docs.gradle.com/develocity/gradle-plugin/current/#obfuscating_identifying_data

```java
develocity {
    buildScan {        
        obfuscation {
            username { _ -> "eclipse-" + System.getenv("EF_SHORT_NAME") + "-bot" }
            ipAddresses { addresses -> addresses.map { _ -> "0.0.0.0" } }
        }
    }
}
```

2. Maven: `.mvn/develocity.xml`

doc: https://docs.gradle.com/develocity/maven-extension/current/#obfuscating_identifying_data

```xml
<develocity>
  ...
  <buildScan>
    <obfuscation>
      <username>#{'eclipse-' + env['EF_SHORT_NAME'] + '-bot'}</username>
      <ipAddresses>'0.0.0.0'</ipAddresses>
    </obfuscation>
  </buildScan>
</develocity>
```

#### Tags

1. Gradle: `build.gradle.kts`

doc: https://docs.gradle.com/develocity/gradle-plugin/current/#adding_tags

e.g: with Gitlab CI 

```java
develocity {
    buildScan {
        tag(System.getenv("EF_SHORT_NAME"))
        tag("GitLab CI")
        link("VCS", "${System.getenv("CI_PROJECT_URL")}/-/tree/${System.getenv("CI_COMMIT_REF_NAME")}?ref_type=heads")
        value("Build Number", "${System.getenv("CI_PIPELINE_ID")}")
    }
}
```

2. Maven: `.mvn/develocity.xml`

doc: https://docs.gradle.com/develocity/maven-extension/current/#adding_tags

```xml
<buildScan>
    <tags>
      <tag>#{env['EF_SHORT_NAME']}</tag>
      <tag>maven</tag>
      <tag>Gitlab CI</tag>
    </tags>
</buildScan>
```

## Support

* [HelpDesk](https://gitlab.eclipse.org/eclipsefdn/helpdesk/-/issues/new)
* [IT chat service room: #eclipsefdn.it:matrix.eclipse.org](https://chat.eclipse.org/#/room/#eclipsefdn.it:matrix.eclipse.org)

## Useful link

* [Develocity Documentation](https://gradle.com/develocity/resources/)
* [Gradle integration](https://docs.gradle.com/develocity/get-started/)
* [Maven integration](https://docs.gradle.com/develocity/maven-get-started/)
* [CI Integration](https://docs.gradle.com/develocity/get-started/#integrating_your_ci_tool)
* [GitLab CI templates](https://gitlab.eclipse.org/eclipsefdn/it/releng/gitlab-runner-service/gitlab-ci-templates)
* [GitHub Action Gradle](https://docs.gradle.com/develocity/get-started/#github_actions)
* [Develocity maven GitHub Action](https://github.com/gradle/develocity-actions)
* [Develocity Gradle GitHub Action](https://github.com/gradle/gradle-build-action)
* [Gradle obfuscation](https://docs.gradle.com/develocity/gradle-plugin/current/#obfuscating_identifying_data)
* [Maven obfuscation](https://docs.gradle.com/develocity/maven-extension/current/#obfuscating_identifying_data)
* [Gradle tags](https://docs.gradle.com/develocity/gradle-plugin/current/#adding_tags)
* [Maven tags](https://docs.gradle.com/develocity/maven-extension/current/#adding_tags)