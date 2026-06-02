#!/bin/sh
set -e

log() {
  echo "[$(date +%Y-%m-%d:%H:%M:%S)]: $1"
}

error_exit() {
  log "$1" 1>&2
  exit 1
}

wait_for_tcp() {
  host="$1"
  port="$2"
  name="$3"

  if [ "${SKIP_CONTROL_PLANE_SERVICE_WAIT:-}" = "true" ]; then
    log "Skipping wait for ${name}"
    return
  fi

  log "Waiting for ${name} at ${host}:${port}"
  for _ in $(seq 1 90); do
    if ruby -rsocket -e "TCPSocket.new('${host}', ${port}).close"; then
      return
    fi
    sleep 2
  done

  error_exit "Timed out waiting for ${name}"
}

production_app() {
  case "${CPLN_GVC:-${BRANCH:-}}" in
    *-production) return 0 ;;
    *) return 1 ;;
  esac
}

require_env() {
  name="$1"
  eval "value=\${${name}:-}"
  if [ -z "$value" ]; then
    error_exit "${name} must be configured before promoting the Control Plane production app"
  fi
}

log "Running release_script.sh per controlplane.yml"

if production_app; then
  require_env "RECAPTCHA_LOGIN_SITE_KEY"
  require_env "ENTERPRISE_RECAPTCHA_API_KEY"
fi

wait_for_tcp "${DATABASE_HOST}" "${DATABASE_PORT:-3306}" mysql
wait_for_tcp "redis.${CPLN_GVC:-${BRANCH}}.cpln.local" 6379 redis
wait_for_tcp "mongo.${CPLN_GVC:-${BRANCH}}.cpln.local" 27017 mongo
wait_for_tcp "memcached.${CPLN_GVC:-${BRANCH}}.cpln.local" 11211 memcached
wait_for_tcp "elasticsearch.${CPLN_GVC:-${BRANCH}}.cpln.local" 9200 elasticsearch

if [ -x ./bin/rails ]; then
  log "Run DB migrations"
  SECRET_KEY_BASE="${SECRET_KEY_BASE:-precompile_placeholder}" ./bin/rails db:prepare || \
    error_exit "Failed to run DB migrations"

  if [ "${ALLOW_DEMO_SEED:-}" = "true" ]; then
    log "Seed demo data because ALLOW_DEMO_SEED=true"
    SECRET_KEY_BASE="${SECRET_KEY_BASE:-precompile_placeholder}" ./bin/rails db:seed || \
      error_exit "Failed to seed demo data"
  fi
else
  error_exit "./bin/rails does not exist or is not executable"
fi

log "Completed release_script.sh per controlplane.yml"
