#!/bin/bash

set -e

echo "Starting Gerrit version ${GERRIT_VERSION}, release ${GERRIT_RELEASE}"
sudo -u  ${GERRIT_USER} $GERRIT_HOME/bin/gerrit.sh ${GERRIT_START_ACTION:-daemon}
