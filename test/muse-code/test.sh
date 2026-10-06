#!/bin/bash

# Runs against an auto-generated devcontainer.json that includes the
# 'muse-code' Feature with no options. The install talks to Meta's servers,
# so this only checks that the launcher and binary landed.
#
#    devcontainer features test \
#        --features muse-code \
#        --skip-scenarios \
#        --base-image mcr.microsoft.com/devcontainers/base:ubuntu \
#        /path/to/this/repo

set -e

source dev-container-features-test-lib

check "muse is on PATH" bash -c "command -v muse"
check "launcher is executable" bash -c 'test -x "$(readlink -f "$(command -v muse)")"'
check "binary was downloaded" bash -c 'ls "$(dirname "$(readlink -f "$(command -v muse)")")"/muse-bin-* >/dev/null'
check "profile.d snippet exists" test -f /etc/profile.d/muse-code.sh

reportResults
