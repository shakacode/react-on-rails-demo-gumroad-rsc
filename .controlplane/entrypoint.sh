#!/bin/sh
set -e

is_rails_server_command() {
  if [ "${1:-}" = "bundle" ] && [ "${2:-}" = "exec" ]; then
    shift 2
  fi

  { [ "${1:-}" = "rails" ] || [ "${1:-}" = "bin/rails" ] || [ "${1:-}" = "./bin/rails" ]; } &&
    { [ "${2:-}" = "server" ] || [ "${2:-}" = "s" ]; }
}

if is_rails_server_command "$@"; then
  echo " -- Preparing database"
  ./bin/rails db:prepare
fi

echo " -- Finishing entrypoint.sh, executing command"
exec "$@"
