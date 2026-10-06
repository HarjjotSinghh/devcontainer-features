#!/bin/bash

set -e

source dev-container-features-test-lib

check "launcher in vscode's ~/.local/bin" test -x /home/vscode/.local/bin/muse
check "owned by vscode" bash -c 'test "$(stat -c %U /home/vscode/.local/bin/muse)" = vscode'
check "muse is on PATH" bash -c "command -v muse"

reportResults
