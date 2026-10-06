#!/bin/bash

set -e

source dev-container-features-test-lib

check "muse is on PATH" bash -c "command -v muse"
check "launcher in root's ~/.local/bin" test -x /root/.local/bin/muse

reportResults
