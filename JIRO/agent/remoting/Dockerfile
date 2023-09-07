#*******************************************************************************
# Copyright (c) 2020 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************
FROM %(from)s

# These environment variables will be used in the uid_entrypoint script from the parent image
ENV USER_NAME="%(username)s"
ENV HOME="%(home)s"

VOLUME [ "%(home)s", ]
WORKDIR "%(home)s"
ENTRYPOINT [ "uid_entrypoint", "%(startupScript)s" ]

ADD "%(remotingJarUrl)s" "%(remotingJar)s" 
ADD "%(startupScriptUrl)s" "%(startupScript)s"

RUN sed -e 's/JAVA_OPTS/JAVA_OPTS \$JENKINS_REMOTING_JAVA_OPTS/g' %(startupScript)s > %(startupScript)s.sed \
    && mv %(startupScript)s.sed %(startupScript)s

RUN chmod 755 "$(dirname "%(remotingJar)s")" \
  && chmod 644 "%(remotingJar)s" \
  && chmod ug+rx "%(startupScript)s" \
  && chgrp 0 "%(startupScript)s"

USER 10001:0
