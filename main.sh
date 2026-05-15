#!/bin/bash

# Root-level entry point that delegates to the orchestrator in src/init.sh.
# Forwards all arguments through, so flags like --all, --brew, --help work
# identically when invoked from the repo root.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec bash "$SCRIPT_DIR/src/init.sh" "$@"
