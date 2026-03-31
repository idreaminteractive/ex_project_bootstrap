#!/bin/bash

set -eou pipefail
log()  { echo ""; echo "▶ $1..."; }
ok()   { echo "  ✓ done"; }

log "Setup of mise deps"
mise trust
mise i
ok

log "Setup of mise env"
mise exec -- task init
mise exec -- mix ash.setup

log "Starting dev server"
mise exec -- task dev
ok
