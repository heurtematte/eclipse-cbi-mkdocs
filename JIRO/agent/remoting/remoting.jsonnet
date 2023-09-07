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
  # See https://github.com/jenkinsci/remoting/releases for the remoting version
  # See https://github.com/jenkinsci/docker-inbound-agent/releases for the startupScript.version
  latest: "3107.v665000b_51092",
  releases: [
    default + {
      // Included since LTS 2.414.1
      version: "3131.vf2b_b_798b_ce99",
      startupScript+: {
        version: "3131.vf2b_b_798b_ce99-5",
      },
    },
    default + {
      // Included since ??
      version: "3107.v665000b_51092",
      startupScript+: {
        version: "3107.v665000b_51092-15",
      },
    },
    default + {
      // Included since ??
      version: "3077.vd69cf116da_6f",
      startupScript+: {
        version: "3077.vd69cf116da_6f-4",
      },
    },
  ],
}