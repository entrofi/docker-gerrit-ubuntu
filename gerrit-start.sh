#!/bin/bash

set -e

echo "Starting Gerrit..."
sudo -u  ${GERRIT_USER} $GERRIT_HOME/bin/gerrit.sh ${GERRIT_START_ACTION:-daemon}
