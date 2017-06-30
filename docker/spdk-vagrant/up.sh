#!/usr/bin/env bash

set -e

# command `/sbin/vboxconfig` will fail on calling `systemctl daemon-reexec`
# with error message "Failed to connect to bus: No such file or directory"
# for several times.
# This is expected and unaffected because This command is of little use
# except for debugging and package upgrades.
cd scripts/vagrant && \
        source ./env.sh && \
        vagrant up && \
        vagrant ssh
