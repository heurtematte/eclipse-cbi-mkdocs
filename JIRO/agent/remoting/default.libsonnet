#*******************************************************************************
# Copyright (c) 2020 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************
{
  version: error "Must specify version",
  # <jar> must match the path declared in the startupScript 
  # Look at the "-cp <jar>" for a given version
  jar: "/usr/share/jenkins/agent.jar",
  url: "https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/%s/remoting-%s.jar" % [ self.version, self.version, ],
  startupScript: {
    name: "jenkins-agent",
    version: error "Must specify startupScript version",
    url: "https://github.com/jenkinsci/docker-inbound-agent/raw/%s/%s" % [ self.version, self.name, ],
  },
}