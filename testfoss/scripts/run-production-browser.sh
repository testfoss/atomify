#!/usr/bin/env bash
set -euo pipefail

TESTFOSS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT="$(cd "$TESTFOSS_ROOT/.." && pwd)"
TOOLS="$TESTFOSS_ROOT/.tools"
RESULTS="$TESTFOSS_ROOT/results"
PORT="${ATOMIFY_PORT:-5201}"
export PATH="$TOOLS/lmctl/node_modules/.bin:$TOOLS/bin:$PATH"
export ATOMIFY_URL="${ATOMIFY_URL:-http://127.0.0.1:$PORT}"
export ATOMIFY_FIXTURE="$TESTFOSS_ROOT/fixtures/in.smoke-lj"

command -v lmscript > /dev/null
command -v lmwebtest > /dev/null
mkdir -p "$RESULTS"
cd "$ROOT"
npm run preview -- --host 127.0.0.1 --port "$PORT" --strictPort > "$RESULTS/server.log" 2>&1 &
SERVER_PID=$!
trap 'kill "$SERVER_PID" 2> /dev/null || true; wait "$SERVER_PID" 2> /dev/null || true' EXIT
for _ in $(seq 1 60); do
  if curl --fail --silent --output /dev/null "$ATOMIFY_URL/atomify/"; then
    break
  fi
  if ! kill -0 "$SERVER_PID" 2> /dev/null; then
    cat "$RESULTS/server.log"
    exit 1
  fi
  sleep 1
done
curl --fail --silent --output /dev/null "$ATOMIFY_URL/atomify/"
lmscript "$TESTFOSS_ROOT/browser/production.lms"
