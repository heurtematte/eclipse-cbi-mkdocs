#*******************************************************************************
# Copyright (c) 2020 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************
local default = import "default.libsonnet";
{
  [agent.spec.name]: agent for agent in [
    default + {
      spec+: {
        name: "basic",
        labels: ["basic"],
        mode: "NORMAL", # utilize agent as much as possible
        docker+: {
          raw_dockerfile:: importstr "basic/Dockerfile",
        },
      },
      variants+: default.addAliases(super.variants, [
        "docker.io/eclipsecbijenkins/basic-agent:%s",
        "docker.io/eclipsecbijenkins/jenkins-agent:%s",
        "docker.io/eclipsecbi/jenkins-jnlp-agent:%s", 
      ]),
    },
    default + {
      spec+: {
        name: "basic-ubuntu",
        labels: ["basic-ubuntu"],
        docker+: {
          raw_dockerfile:: importstr "basic-ubuntu/Dockerfile",
        },
      },
    },
    default + {
      spec+: {
        name: "centos-7",
        labels: ["migration", "jipp-migration", "centos-7" ],
        docker+: {
          raw_dockerfile:: importstr "centos-7/Dockerfile",
        },
      },
      variants+: default.addAliases(super.variants, [ 
        "docker.io/eclipsecbijenkins/jipp-migration-agent:%s", 
        "docker.io/eclipsecbijenkins/migration-fat-agent:%s",
        "docker.io/eclipsecbijenkins/ui-test-agent:%s",
        "docker.io/eclipsecbijenkins/ui-tests-agent:%s", 
      ]),
    },
    default + {
      spec+: {
        name: "centos-8",
        labels: ["centos-latest", "centos-8" ],
        docker+: {
          raw_dockerfile:: importstr "centos-8/Dockerfile",
        },
      },
    },
  ]
}
